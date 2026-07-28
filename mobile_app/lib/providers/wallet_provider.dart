import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/csr_sponsor_model.dart';
import 'package:mobile_app/models/reward_incentive_model.dart';
import 'package:mobile_app/models/wallet_model.dart';
import 'package:mobile_app/models/wallet_transaction_model.dart';
import 'package:mobile_app/models/withdrawal_request_model.dart';
import 'package:mobile_app/repositories/wallet_repository.dart';

class WalletState {
  final WalletModel? wallet;
  final List<WalletTransactionModel> transactions;
  final List<WithdrawalRequestModel> withdrawals;
  final List<CsrSponsorModel> sponsors;
  final List<RewardIncentiveModel> rewards;
  final bool isLoading;
  final String? error;

  const WalletState({
    this.wallet,
    this.transactions = const [],
    this.withdrawals = const [],
    this.sponsors = const [],
    this.rewards = const [],
    this.isLoading = false,
    this.error,
  });

  WalletState copyWith({
    WalletModel? wallet,
    List<WalletTransactionModel>? transactions,
    List<WithdrawalRequestModel>? withdrawals,
    List<CsrSponsorModel>? sponsors,
    List<RewardIncentiveModel>? rewards,
    bool? isLoading,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      withdrawals: withdrawals ?? this.withdrawals,
      sponsors: sponsors ?? this.sponsors,
      rewards: rewards ?? this.rewards,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletRepository _repository;

  WalletNotifier(this._repository) : super(const WalletState());

  Future<void> loadWalletData(String uid) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final wallet = await _repository.getWallet(uid);
      final txns = await _repository.getTransactions(uid);
      final wds = await _repository.getWithdrawalHistory(uid);
      final sps = await _repository.getCsrSponsors();
      final rwds = await _repository.getRewardsAndIncentives(uid);

      state = state.copyWith(
        wallet: wallet,
        transactions: txns,
        withdrawals: wds,
        sponsors: sps,
        rewards: rwds,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> requestWithdrawal({
    required String driverUid,
    required String driverName,
    required double amount,
    required String bankName,
    required String accountHolder,
    required String accountNumber,
    required String ifscCode,
    required String upiId,
  }) async {
    final success = await _repository.requestWithdrawal(
      driverUid: driverUid,
      driverName: driverName,
      amount: amount,
      bankName: bankName,
      accountHolder: accountHolder,
      accountNumber: accountNumber,
      ifscCode: ifscCode,
      upiId: upiId,
    );

    if (success) {
      await loadWalletData(driverUid);
    }
    return success;
  }
}
