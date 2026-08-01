import 'package:mobile_app/models/community_leaderboard_model.dart';
import 'package:mobile_app/models/home_cook_profile_model.dart';
import 'package:mobile_app/models/verification_request_model.dart';

abstract class HomeCookRepository {
  Future<HomeCookProfileModel?> getHomeCookProfile(String uid);
  Stream<HomeCookProfileModel?> streamHomeCookProfile(String uid);
  Future<List<CommunityLeaderboardModel>> getLeaderboard(LeaderboardCategory category);
  Future<bool> submitVerificationRequest(VerificationRequestModel request);
  Future<List<VerificationRequestModel>> adminGetPendingVerificationRequests();
  Future<bool> adminApproveVerification({
    required String requestId,
    required String uid,
    required VerificationLevel newLevel,
    required bool approve,
  });
}
