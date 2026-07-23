import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/delivery_request_model.dart';

abstract class VolunteerRepository {
  Future<ApiResult<List<DeliveryRequestModel>>> getAvailableDeliveries();
  Stream<List<DeliveryRequestModel>> streamAvailableDeliveries();
  Future<ApiResult<DeliveryRequestModel>> acceptDeliveryTask({
    required String deliveryId,
    required String volunteerId,
    required String volunteerName,
  });
  Future<ApiResult<DeliveryRequestModel>> updateDeliveryStatus({
    required String deliveryId,
    required String status,
  });
  Future<ApiResult<List<DeliveryRequestModel>>> getVolunteerDeliveries(String volunteerId);
  Future<ApiResult<List<DeliveryRequestModel>>> getVolunteerHistory(String volunteerId);
}
