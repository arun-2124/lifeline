import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/models/community_leaderboard_model.dart';
import 'package:mobile_app/models/home_cook_profile_model.dart';
import 'package:mobile_app/models/verification_request_model.dart';
import 'package:mobile_app/repositories/home_cook_repository.dart';

class HomeCookState {
  final HomeCookProfileModel? profile;
  final List<CommunityLeaderboardModel> leaderboard;
  final List<VerificationRequestModel> pendingRequests;
  final bool isLoading;
  final String? error;

  const HomeCookState({
    this.profile,
    this.leaderboard = const [],
    this.pendingRequests = const [],
    this.isLoading = false,
    this.error,
  });

  HomeCookState copyWith({
    HomeCookProfileModel? profile,
    List<CommunityLeaderboardModel>? leaderboard,
    List<VerificationRequestModel>? pendingRequests,
    bool? isLoading,
    String? error,
  }) {
    return HomeCookState(
      profile: profile ?? this.profile,
      leaderboard: leaderboard ?? this.leaderboard,
      pendingRequests: pendingRequests ?? this.pendingRequests,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class HomeCookNotifier extends StateNotifier<HomeCookState> {
  final HomeCookRepository _repository;

  HomeCookNotifier(this._repository) : super(const HomeCookState());

  Future<void> loadProfile(String uid) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getHomeCookProfile(uid);
      final leaderboard = await _repository.getLeaderboard(LeaderboardCategory.homeCooks);
      state = state.copyWith(profile: profile, leaderboard: leaderboard, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> submitVerificationRequest(VerificationRequestModel request) async {
    final success = await _repository.submitVerificationRequest(request);
    if (success) {
      await loadProfile(request.uid);
    }
    return success;
  }
}
