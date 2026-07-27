import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/models/monetary_donation_model.dart';

abstract class DonationRepository {
  Future<ApiResult<DonationModel>> createDonation(DonationModel donation);
  Future<ApiResult<List<DonationModel>>> getDonorDonations(String donorId);
  Stream<List<DonationModel>> streamDonorDonations(String donorId);
  Future<ApiResult<DonationModel>> getDonationById(String donationId);
  Future<ApiResult<DonationModel>> updateDonation(DonationModel donation);
  Future<ApiResult<void>> cancelDonation(String donationId, String reason);
  Future<ApiResult<MonetaryDonationModel>> submitMonetaryDonation(MonetaryDonationModel donation);
  Future<ApiResult<double>> getTotalFundsRaised();
}
