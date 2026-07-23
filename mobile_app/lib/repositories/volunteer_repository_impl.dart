import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/core/errors/failures.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/delivery_request_model.dart';
import 'package:mobile_app/models/notification_model.dart';
import 'package:mobile_app/repositories/volunteer_repository.dart';
import 'package:mobile_app/services/firestore_service.dart';
import 'package:mobile_app/utils/app_logger.dart';

class VolunteerRepositoryImpl implements VolunteerRepository {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _firestore;

  VolunteerRepositoryImpl({
    required FirestoreService firestoreService,
    FirebaseFirestore? firestore,
  })  : _firestoreService = firestoreService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ApiResult<List<DeliveryRequestModel>>> getAvailableDeliveries() async {
    try {
      final querySnap = await _firestore
          .collection('delivery_requests')
          .where('status', isEqualTo: 'Waiting for Volunteer')
          .orderBy('createdAt', descending: true)
          .get();

      final list = querySnap.docs
          .map((doc) => DeliveryRequestModel.fromMap(doc.data(), doc.id))
          .toList();

      return ApiResult.success(list);
    } catch (e) {
      AppLogger.e('Failed to fetch available deliveries: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch available deliveries: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<List<DeliveryRequestModel>> streamAvailableDeliveries() {
    return _firestore
        .collection('delivery_requests')
        .where('status', isEqualTo: 'Waiting for Volunteer')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DeliveryRequestModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<ApiResult<DeliveryRequestModel>> acceptDeliveryTask({
    required String deliveryId,
    required String volunteerId,
    required String volunteerName,
  }) async {
    try {
      final docRef = _firestore.collection('delivery_requests').doc(deliveryId);
      final assignmentRef = _firestore.collection('volunteer_assignments').doc();
      final now = DateTime.now();

      final snap = await docRef.get();
      if (!snap.exists || snap.data() == null) {
        return ApiResult.failure(const CacheFailure(message: 'Delivery request not found.'));
      }

      final delivery = DeliveryRequestModel.fromMap(snap.data()!, snap.id);
      final updated = delivery.copyWith(
        status: 'Volunteer Assigned',
        volunteerId: volunteerId,
        volunteerName: volunteerName,
        updatedAt: now,
      );

      final batch = _firestore.batch();

      // 1. Update status in delivery_requests
      batch.update(docRef, {
        'status': 'Volunteer Assigned',
        'volunteerId': volunteerId,
        'volunteerName': volunteerName,
        'updatedAt': now.toIso8601String(),
      });

      // 2. Save volunteer_assignments document
      batch.set(assignmentRef, {
        'assignmentId': assignmentRef.id,
        'deliveryId': deliveryId,
        'volunteerId': volunteerId,
        'volunteerName': volunteerName,
        'assignedAt': now.toIso8601String(),
        'status': 'Active',
      });

      // 3. Update main donation status to 'Matched' / 'In Transit'
      final donationRef = _firestore.collection('donations').doc(delivery.donationId);
      batch.update(donationRef, {
        'status': 'In Transit',
        'volunteerId': volunteerId,
        'volunteerName': volunteerName,
        'updatedAt': now.toIso8601String(),
      });

      // 4. Send Notification to Donor
      final notifRef = _firestore.collection('notifications').doc();
      final notif = NotificationModel(
        notificationId: notifRef.id,
        userId: delivery.donorId,
        title: 'Volunteer Assigned!',
        body: '$volunteerName is assigned to pick up your food donation "${delivery.foodName}".',
        type: 'pickup_update',
        createdAt: now,
      );
      batch.set(notifRef, notif.toMap());

      await batch.commit();

      AppLogger.i('Delivery task accepted by volunteer: $volunteerId');
      return ApiResult.success(updated);
    } catch (e) {
      AppLogger.e('Failed to accept delivery task: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to accept delivery task: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<DeliveryRequestModel>> updateDeliveryStatus({
    required String deliveryId,
    required String status,
  }) async {
    try {
      final docRef = _firestore.collection('delivery_requests').doc(deliveryId);
      final now = DateTime.now();

      await _firestoreService.updateDocument(
        collection: 'delivery_requests',
        docId: deliveryId,
        data: {
          'status': status,
          'updatedAt': now.toIso8601String(),
        },
      );

      final snap = await docRef.get();
      final updated = DeliveryRequestModel.fromMap(snap.data()!, snap.id);

      // If status is Delivered or Completed, write to delivery_history
      if (status == 'Completed' || status == 'Delivered') {
        final historyRef = _firestore.collection('delivery_history').doc();
        await _firestoreService.setDocument(
          collection: 'delivery_history',
          docId: historyRef.id,
          data: {
            'historyId': historyRef.id,
            'deliveryId': deliveryId,
            'volunteerId': updated.volunteerId,
            'status': status,
            'completedAt': now.toIso8601String(),
          },
        );

        // Update main donation status as well
        await _firestoreService.updateDocument(
          collection: 'donations',
          docId: updated.donationId,
          data: {'status': status, 'completedAt': now.toIso8601String()},
        );
      }

      return ApiResult.success(updated);
    } catch (e) {
      AppLogger.e('Failed to update delivery status: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to update delivery status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<List<DeliveryRequestModel>>> getVolunteerDeliveries(String volunteerId) async {
    try {
      final querySnap = await _firestore
          .collection('delivery_requests')
          .where('volunteerId', isEqualTo: volunteerId)
          .orderBy('updatedAt', descending: true)
          .get();

      final list = querySnap.docs
          .map((doc) => DeliveryRequestModel.fromMap(doc.data(), doc.id))
          .toList();

      return ApiResult.success(list);
    } catch (e) {
      AppLogger.e('Failed to fetch volunteer deliveries: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch volunteer deliveries: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<List<DeliveryRequestModel>>> getVolunteerHistory(String volunteerId) async {
    try {
      final querySnap = await _firestore
          .collection('delivery_requests')
          .where('volunteerId', isEqualTo: volunteerId)
          .where('status', whereIn: ['Delivered', 'Completed'])
          .orderBy('updatedAt', descending: true)
          .get();

      final list = querySnap.docs
          .map((doc) => DeliveryRequestModel.fromMap(doc.data(), doc.id))
          .toList();

      return ApiResult.success(list);
    } catch (e) {
      AppLogger.e('Failed to fetch volunteer history: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch volunteer history: ${e.toString()}'),
      );
    }
  }
}
