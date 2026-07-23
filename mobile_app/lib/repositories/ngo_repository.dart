import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/models/ngo_request_model.dart';
import 'package:mobile_app/models/notification_model.dart';

abstract class NgoRepository {
  Future<ApiResult<List<DonationModel>>> getAvailableDonations();
  Stream<List<DonationModel>> streamAvailableDonations();
  Future<ApiResult<NgoRequestModel>> acceptDonation({
    required DonationModel donation,
    required String ngoId,
    required String ngoName,
    String? notes,
  });
  Future<ApiResult<List<NgoRequestModel>>> getAcceptedRequests(String ngoId);
  Future<ApiResult<List<NotificationModel>>> getNgoNotifications(String userId);
  Future<ApiResult<void>> markNotificationRead(String notificationId);
}
