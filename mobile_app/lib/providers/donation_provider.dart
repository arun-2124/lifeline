import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/models/monetary_donation_model.dart';
import 'package:mobile_app/repositories/donation_repository.dart';

class DonationState {
  final bool isLoading;
  final List<DonationModel> donations;
  final DonationModel? selectedDonation;
  final double totalFundsRaised;
  final String? errorMessage;
  final String? infoMessage;

  const DonationState({
    this.isLoading = false,
    this.donations = const [],
    this.selectedDonation,
    this.totalFundsRaised = 15450.0,
    this.errorMessage,
    this.infoMessage,
  });

  DonationState copyWith({
    bool? isLoading,
    List<DonationModel>? donations,
    DonationModel? selectedDonation,
    double? totalFundsRaised,
    String? errorMessage,
    String? infoMessage,
  }) {
    return DonationState(
      isLoading: isLoading ?? this.isLoading,
      donations: donations ?? this.donations,
      selectedDonation: selectedDonation ?? this.selectedDonation,
      totalFundsRaised: totalFundsRaised ?? this.totalFundsRaised,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }
}

class DonationNotifier extends StateNotifier<DonationState> {
  final DonationRepository _repository;

  DonationNotifier({required DonationRepository repository})
      : _repository = repository,
        super(const DonationState()) {
    loadTotalFunds();
  }

  Future<void> loadTotalFunds() async {
    final result = await _repository.getTotalFundsRaised();
    if (result is ApiSuccess<double>) {
      state = state.copyWith(totalFundsRaised: result.data);
    }
  }

  Future<void> loadDonorDonations(String donorId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getDonorDonations(donorId);

    if (result is ApiSuccess<List<DonationModel>>) {
      state = state.copyWith(
        isLoading: false,
        donations: result.data,
      );
    } else if (result is ApiFailure<List<DonationModel>>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
    }
  }

  Future<bool> createDonation(DonationModel donation) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.createDonation(donation);

    if (result is ApiSuccess<DonationModel>) {
      final updatedList = [result.data, ...state.donations];
      state = state.copyWith(
        isLoading: false,
        donations: updatedList,
        infoMessage: 'Donation published successfully!',
      );
      return true;
    } else if (result is ApiFailure<DonationModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
    return false;
  }

  Future<bool> submitMonetaryDonation(MonetaryDonationModel donation) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.submitMonetaryDonation(donation);

    if (result is ApiSuccess<MonetaryDonationModel>) {
      final newTotal = state.totalFundsRaised + donation.amount;
      state = state.copyWith(
        isLoading: false,
        totalFundsRaised: newTotal,
        infoMessage: 'Thank you! Your donation of ${donation.currency}${donation.amount} was received.',
      );
      return true;
    } else if (result is ApiFailure<MonetaryDonationModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
    return false;
  }

  Future<bool> updateDonation(DonationModel donation) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.updateDonation(donation);

    if (result is ApiSuccess<DonationModel>) {
      final updatedList = state.donations.map((d) {
        return d.donationId == donation.donationId ? result.data : d;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        donations: updatedList,
        selectedDonation: result.data,
        infoMessage: 'Donation updated successfully!',
      );
      return true;
    } else if (result is ApiFailure<DonationModel>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
    return false;
  }

  Future<bool> cancelDonation(String donationId, String reason) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.cancelDonation(donationId, reason);

    if (result is ApiSuccess<void>) {
      final updatedList = state.donations.map((d) {
        return d.donationId == donationId ? d.copyWith(status: 'Cancelled') : d;
      }).toList();

      state = state.copyWith(
        isLoading: false,
        donations: updatedList,
        infoMessage: 'Donation cancelled.',
      );
      return true;
    } else if (result is ApiFailure<void>) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: result.failure.message,
      );
      return false;
    }
    return false;
  }

  void selectDonation(DonationModel donation) {
    state = state.copyWith(selectedDonation: donation);
  }
}
