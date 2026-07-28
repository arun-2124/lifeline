import 'package:mobile_app/models/csr_sponsor_model.dart';
import 'package:mobile_app/models/reward_incentive_model.dart';
import 'package:mobile_app/models/wallet_model.dart';
import 'package:mobile_app/models/wallet_transaction_model.dart';
import 'package:mobile_app/models/withdrawal_request_model.dart';

abstract class WalletRepository {
  Future<WalletModel?> getWallet(String uid);
  Stream<WalletModel?> streamWallet(String uid);
  Future<List<WalletTransactionModel>> getTransactions(String uid);
  Future<List<WithdrawalRequestModel>> getWithdrawalHistory(String uid);
  Future<List<CsrSponsorModel>> getCsrSponsors();
  Future<List<RewardIncentiveModel>> getRewardsAndIncentives(String uid);

  Future<bool> requestWithdrawal({
    required String driverUid,
    required String driverName,
    required double amount,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String ifscCode,
    required String upiId,
  });

  Future<bool> recordDeliveryEarnings({
    required String driverUid,
    required String deliveryId,
    required String donationId,
    required double basePay,
    required double distancePay,
    required double peakHourBonus,
    required double carbonBonus,
    required double ratingBonus,
    required double tip,
    required PaymentSource paymentSource,
  });

  Future<bool> adminApproveWithdrawal({
    required String withdrawalId,
    required String driverUid,
    required double amount,
    required bool approve,
    String? note,
  });

  Future<List<WithdrawalRequestModel>> adminGetAllPendingWithdrawals();
}
