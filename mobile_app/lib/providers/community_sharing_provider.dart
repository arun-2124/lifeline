import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/community_donation_model.dart';
import 'package:mobile_app/models/community_donor_model.dart';
import 'package:mobile_app/repositories/community_sharing_repository.dart';

class CommunitySharingState {
  final List<CommunityDonationModel> donations;
  final CommunityDonorModel? currentDonor;
  final bool isLoading;
  final String? error;

  const CommunitySharingState({
    this.donations = const [],
    this.currentDonor,
    this.isLoading = false,
    this.error,
  });

  CommunitySharingState copyWith({
    List<CommunityDonationModel>? donations,
    CommunityDonorModel? currentDonor,
    bool? isLoading,
    String? error,
  }) {
    return CommunitySharingState(
      donations: donations ?? this.donations,
      currentDonor: currentDonor ?? this.currentDonor,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CommunitySharingNotifier extends StateNotifier<CommunitySharingState> {
  final CommunitySharingRepository _repository;

  CommunitySharingNotifier(this._repository) : super(const CommunitySharingState());

  Future<void> loadCommunityDonations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getCommunityDonations();
      state = state.copyWith(donations: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createDonation(CommunityDonationModel donation) async {
    final success = await _repository.createCommunityDonation(donation);
    if (success) {
      await loadCommunityDonations();
    }
    return success;
  }

  Future<bool> reserveFood(String donationId, String recipientUid) async {
    final success = await _repository.reserveCommunityFood(
      donationId: donationId,
      recipientUid: recipientUid,
    );
    if (success) {
      await loadCommunityDonations();
    }
    return success;
  }
}
