import 'package:mobile_app/models/community_chat_message_model.dart';
import 'package:mobile_app/models/community_donation_model.dart';
import 'package:mobile_app/models/community_donor_model.dart';

abstract class CommunitySharingRepository {
  Future<List<CommunityDonationModel>> getCommunityDonations();
  Stream<List<CommunityDonationModel>> streamCommunityDonations();
  Future<CommunityDonorModel?> getCommunityDonor(String uid);

  Future<bool> createCommunityDonation(CommunityDonationModel donation);
  Future<bool> reserveCommunityFood({
    required String donationId,
    required String recipientUid,
  });

  Stream<List<CommunityChatMessageModel>> streamChatMessages(String donationId);
  Future<bool> sendChatMessage(CommunityChatMessageModel message);

  Future<bool> submitCommunityRating({
    required String donationId,
    required String raterUid,
    required String targetUid,
    required double rating,
    required String comment,
  });
}
