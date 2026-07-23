import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/core/errors/failures.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/delivery_log_model.dart';
import 'package:mobile_app/models/qr_code_model.dart';
import 'package:mobile_app/models/tracking_model.dart';
import 'package:mobile_app/repositories/tracking_repository.dart';
import 'package:mobile_app/services/firestore_service.dart';
import 'package:mobile_app/utils/app_logger.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _firestore;

  TrackingRepositoryImpl({
    required FirestoreService firestoreService,
    FirebaseFirestore? firestore,
  })  : _firestoreService = firestoreService,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<ApiResult<QrCodeModel>> generateDonationQr(String donationId) async {
    try {
      final docRef = _firestore.collection('qr_codes').doc(donationId);
      final existing = await docRef.get();

      final now = DateTime.now();

      if (existing.exists && existing.data() != null) {
        return ApiResult.success(QrCodeModel.fromMap(existing.data()!, existing.id));
      }

      final payloadHash = 'LIFELINE_${donationId.toUpperCase()}_HASH_${now.millisecondsSinceEpoch}';
      final qrCode = QrCodeModel(
        qrId: donationId,
        donationId: donationId,
        payloadHash: payloadHash,
        status: 'ACTIVE',
        createdAt: now,
      );

      await _firestoreService.setDocument(
        collection: 'qr_codes',
        docId: donationId,
        data: qrCode.toMap(),
      );

      // Create initial delivery log
      final logRef = _firestore.collection('delivery_logs').doc();
      await _firestoreService.setDocument(
        collection: 'delivery_logs',
        docId: logRef.id,
        data: DeliveryLogModel(
          logId: logRef.id,
          donationId: donationId,
          stage: 'Donation Created',
          title: 'QR Security Code Generated',
          description: 'Unique digital payload hash attached to surplus food donation.',
          timestamp: now,
          performedBy: 'System Engine',
        ).toMap(),
      );

      AppLogger.i('QR code created for donation: $donationId');
      return ApiResult.success(qrCode);
    } catch (e) {
      AppLogger.e('Failed to generate QR code: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to generate QR code: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<QrCodeModel>> getQrCode(String donationId) async {
    try {
      final doc = await _firestoreService.getDocument(collection: 'qr_codes', docId: donationId);
      if (doc.exists && doc.data() != null) {
        return ApiResult.success(QrCodeModel.fromMap(doc.data()!, doc.id));
      } else {
        return generateDonationQr(donationId);
      }
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch QR code: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<QrCodeModel>> verifyQrCode({
    required String qrId,
    required String scannedBy,
    required String scannedByName,
    required String scannedRole,
  }) async {
    try {
      final qrRef = _firestore.collection('qr_codes').doc(qrId);
      final snap = await qrRef.get();

      if (!snap.exists || snap.data() == null) {
        return ApiResult.failure(
          const CacheFailure(message: 'Invalid QR Code: Document does not exist in Lifeline registry.'),
        );
      }

      final currentQr = QrCodeModel.fromMap(snap.data()!, snap.id);

      if (currentQr.status == 'VERIFIED') {
        return ApiResult.failure(
          const CacheFailure(message: 'Duplicate Scan Detected! This QR code has already been verified.'),
        );
      }

      final now = DateTime.now();
      final verifiedQr = currentQr.copyWith(
        status: 'VERIFIED',
        scannedBy: scannedBy,
        scannedByName: scannedByName,
        scannedRole: scannedRole,
        scannedAt: now,
      );

      final batch = _firestore.batch();
      batch.update(qrRef, verifiedQr.toMap());

      // Update donation status to Completed / Handed Over
      final donationRef = _firestore.collection('donations').doc(currentQr.donationId);
      batch.update(donationRef, {
        'status': 'Completed',
        'verifiedAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      // Add delivery log entry
      final logRef = _firestore.collection('delivery_logs').doc();
      batch.set(logRef, {
        'logId': logRef.id,
        'donationId': currentQr.donationId,
        'stage': 'Completed',
        'title': 'QR Verification Passed',
        'description': 'Scanned & verified by $scannedByName ($scannedRole). Delivery confirmed.',
        'timestamp': now.toIso8601String(),
        'performedBy': '$scannedByName ($scannedRole)',
      });

      await batch.commit();

      AppLogger.i('QR code verified successfully: $qrId');
      return ApiResult.success(verifiedQr);
    } catch (e) {
      AppLogger.e('Failed to verify QR code: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to verify QR code: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<TrackingModel>> updateLiveLocation({
    required String donationId,
    required String deliveryId,
    required String volunteerId,
    required String volunteerName,
    required double lat,
    required double lng,
  }) async {
    try {
      final trackingRef = _firestore.collection('tracking').doc(donationId);
      final updateRef = _firestore.collection('location_updates').doc();

      final now = DateTime.now();
      final tracking = TrackingModel(
        trackingId: donationId,
        donationId: donationId,
        deliveryId: deliveryId,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
        currentLat: lat,
        currentLng: lng,
        speedKmh: 28.5,
        lastUpdated: now,
        estimatedArrivalMinutes: 10,
        distanceRemainingKm: 1.8,
      );

      final batch = _firestore.batch();
      batch.set(trackingRef, tracking.toMap());

      batch.set(updateRef, {
        'updateId': updateRef.id,
        'donationId': donationId,
        'volunteerId': volunteerId,
        'latitude': lat,
        'longitude': lng,
        'timestamp': now.toIso8601String(),
      });

      await batch.commit();
      return ApiResult.success(tracking);
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Failed to update live location: ${e.toString()}'),
      );
    }
  }

  @override
  Stream<TrackingModel?> streamLiveTracking(String donationId) {
    return _firestore
        .collection('tracking')
        .doc(donationId)
        .snapshots()
        .map((snap) {
      if (snap.exists && snap.data() != null) {
        return TrackingModel.fromMap(snap.data()!, snap.id);
      }
      return null;
    });
  }

  @override
  Future<ApiResult<List<DeliveryLogModel>>> getDeliveryLogs(String donationId) async {
    try {
      final querySnap = await _firestore
          .collection('delivery_logs')
          .where('donationId', isEqualTo: donationId)
          .orderBy('timestamp', descending: false)
          .get();

      final logs = querySnap.docs
          .map((doc) => DeliveryLogModel.fromMap(doc.data(), doc.id))
          .toList();

      return ApiResult.success(logs);
    } catch (e) {
      AppLogger.e('Failed to fetch delivery logs: $e');
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch delivery logs: ${e.toString()}'),
      );
    }
  }
}
