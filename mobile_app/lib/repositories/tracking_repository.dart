import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/delivery_log_model.dart';
import 'package:mobile_app/models/qr_code_model.dart';
import 'package:mobile_app/models/tracking_model.dart';

abstract class TrackingRepository {
  Future<ApiResult<QrCodeModel>> generateDonationQr(String donationId);
  Future<ApiResult<QrCodeModel>> getQrCode(String donationId);
  Future<ApiResult<QrCodeModel>> verifyQrCode({
    required String qrId,
    required String scannedBy,
    required String scannedByName,
    required String scannedRole,
  });
  Future<ApiResult<TrackingModel>> updateLiveLocation({
    required String donationId,
    required String deliveryId,
    required String volunteerId,
    required String volunteerName,
    required double lat,
    required double lng,
  });
  Stream<TrackingModel?> streamLiveTracking(String donationId);
  Future<ApiResult<List<DeliveryLogModel>>> getDeliveryLogs(String donationId);
}
