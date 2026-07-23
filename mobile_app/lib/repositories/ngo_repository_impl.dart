import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/core/errors/failures.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/models/ngo_request_model.dart';
import 'package:mobile_app/models/notification_model.dart';
import 'package:mobile_app/repositories/ngo_repository.dart';
import 'package:mobile_app/services/firestore_service.dart';
import 'package:mobile_app/utils/app_logger.dart';

class NgoRepositoryImpl implements NgoRepository {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _firestore;

  NgoRepositoryImpl({
    required FirestoreService firestoreService,
    FirebaseFirestore? firestore,
  })  : _firestoreService = firestoreService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ApiResult<List<DonationModel>>> getAvailableDonations() async {
    try {
      final querySnap = await _firestore
          .collection('donations')
          .where('status', isEqualTo: 'Pending')
          .orderBy('createdAt', descending: true)
          .get();

      final donations = querySnap.docs
          .map((doc) => DonationModel.fromMap(doc.data(), doc.id))
          .toList();

      return ApiResult.success(donations);
    } catch (e) {
      AppLogger.e('Failed to fetch available donations: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch available donations: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<List<DonationModel>> streamAvailableDonations() {
    return _firestore
        .collection('donations')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => DonationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  @override
  Future<ApiResult<NgoRequestModel>> acceptDonation({
    required DonationModel donation,
    required String ngoId,
    required String ngoName,
    String? notes,
  }) async {
    try {
      final requestRef = _firestore.collection('ngo_requests').doc();
      final acceptedRef = _firestore.collection('accepted_donations').doc();
      final notificationRef = _firestore.collection('notifications').doc();

      final now = DateTime.now();

      final requestModel = NgoRequestModel(
        requestId: requestRef.id,
        donationId: donation.donationId,
        ngoId: ngoId,
        ngoName: ngoName,
        donorId: donation.donorId,
        donorName: donation.donorName,
        foodName: donation.foodName,
        quantity: donation.quantity,
        unit: donation.unit,
        numberOfMeals: donation.numberOfMeals,
        pickupAddress: donation.pickupAddress,
        latitude: donation.latitude,
        longitude: donation.longitude,
        status: 'Pending',
        requestedAt: now,
        notes: notes,
      );

      final batch = _firestore.batch();

      // 1. Update donation status in `donations`
      final donationRef = _firestore.collection('donations').doc(donation.donationId);
      batch.update(donationRef, {
        'status': 'Accepted',
        'matchedNgoId': ngoId,
        'matchedNgoName': ngoName,
        'acceptedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      // 2. Save `ngo_requests` document
      batch.set(requestRef, requestModel.toMap());

      final deliveryRef = _firestore.collection('delivery_requests').doc();

      // 3. Save `accepted_donations` document
      batch.set(acceptedRef, {
        'acceptedId': acceptedRef.id,
        'donationId': donation.donationId,
        'ngoId': ngoId,
        'donorId': donation.donorId,
        'acceptedAt': now.toIso8601String(),
      });

      // 3b. Create `delivery_requests` document for Volunteer assignment
      batch.set(deliveryRef, {
        'deliveryId': deliveryRef.id,
        'donationId': donation.donationId,
        'requestId': requestRef.id,
        'donorId': donation.donorId,
        'donorName': donation.donorName,
        'donorPhone': donation.contactNumber,
        'pickupAddress': donation.pickupAddress,
        'pickupLat': donation.latitude,
        'pickupLng': donation.longitude,
        'ngoId': ngoId,
        'ngoName': ngoName,
        'ngoPhone': '',
        'destinationAddress': donation.pickupAddress, // Destination location placeholder
        'destLat': donation.latitude,
        'destLng': donation.longitude,
        'foodName': donation.foodName,
        'quantity': donation.quantity,
        'unit': donation.unit,
        'numberOfMeals': donation.numberOfMeals,
        'status': 'Waiting for Volunteer',
        'estimatedDistanceKm': 3.5,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      // 4. Create Notification for Donor
      final notification = NotificationModel(
        notificationId: notificationRef.id,
        userId: donation.donorId,
        title: 'Donation Accepted!',
        body: '$ngoName has accepted your donation "${donation.foodName}". Volunteer pickup assignment in progress.',
        type: 'donation_accepted',
        isRead: false,
        createdAt: now,
        payload: {
          'donationId': donation.donationId,
          'ngoId': ngoId,
          'requestId': requestRef.id,
        },
      );

      batch.set(notificationRef, notification.toMap());

      await batch.commit();

      AppLogger.i('Donation accepted successfully by NGO: $ngoId, Request ID: ${requestRef.id}');
      return ApiResult.success(requestModel);
    } catch (e) {
      AppLogger.e('Failed to accept donation: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to accept donation: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<List<NgoRequestModel>>> getAcceptedRequests(String ngoId) async {
    try {
      final querySnap = await _firestore
          .collection('ngo_requests')
          .where('ngoId', isEqualTo: ngoId)
          .orderBy('requestedAt', descending: true)
          .get();

      final requests = querySnap.docs
          .map((doc) => NgoRequestModel.fromMap(doc.data(), doc.id))
          .toList();

      return ApiResult.success(requests);
    } catch (e) {
      AppLogger.e('Failed to fetch NGO requests: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch NGO requests: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<List<NotificationModel>>> getNgoNotifications(String userId) async {
    try {
      final querySnap = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = querySnap.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();

      return ApiResult.success(notifications);
    } catch (e) {
      AppLogger.e('Failed to fetch notifications: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch notifications: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<void>> markNotificationRead(String notificationId) async {
    try {
      await _firestoreService.updateDocument(
        collection: 'notifications',
        docId: notificationId,
        data: {'isRead': true},
      );
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Failed to update notification: ${e.toString()}'),
      );
    }
  }
}
