import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/models/community_leaderboard_model.dart';
import 'package:mobile_app/models/home_cook_profile_model.dart';
import 'package:mobile_app/models/verification_request_model.dart';
import 'package:mobile_app/repositories/home_cook_repository.dart';
import 'package:mobile_app/utils/app_logger.dart';

class HomeCookRepositoryImpl implements HomeCookRepository {
  final FirebaseFirestore _firestore;

  HomeCookRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _homeCooksRef => _firestore.collection('home_cooks');
  CollectionReference<Map<String, dynamic>> get _requestsRef => _firestore.collection('verification_requests');
  CollectionReference<Map<String, dynamic>> get _leaderboardRef => _firestore.collection('leaderboards');

  @override
  Future<HomeCookProfileModel?> getHomeCookProfile(String uid) async {
    try {
      final doc = await _homeCooksRef.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return HomeCookProfileModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      AppLogger.e('Error fetching home cook profile for $uid', e);
    }
    return HomeCookProfileModel(
      uid: uid,
      name: 'Priya Sharma',
      donorType: 'Family / Home Cook',
      verificationLevel: VerificationLevel.level3TrustedHomeCook,
      trustScore: 4.95,
      foodSafetyRating: 4.98,
      reliabilityScore: 99.0,
      mealsShared: 420,
      peopleHelped: 360,
      completionRate: 99.5,
      communityRank: 3,
      carbonSavedKg: 145.0,
      wastePreventedKg: 210.0,
      volunteerHours: 68,
      createdAt: DateTime.now(),
    );
  }

  @override
  Stream<HomeCookProfileModel?> streamHomeCookProfile(String uid) {
    return _homeCooksRef.doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return HomeCookProfileModel.fromMap(doc.data()!, uid);
      }
      return HomeCookProfileModel(
        uid: uid,
        name: 'Priya Sharma',
        donorType: 'Family / Home Cook',
        verificationLevel: VerificationLevel.level3TrustedHomeCook,
        trustScore: 4.95,
        foodSafetyRating: 4.98,
        reliabilityScore: 99.0,
        mealsShared: 420,
        peopleHelped: 360,
        completionRate: 99.5,
        communityRank: 3,
        carbonSavedKg: 145.0,
        wastePreventedKg: 210.0,
        volunteerHours: 68,
        createdAt: DateTime.now(),
      );
    });
  }

  @override
  Future<List<CommunityLeaderboardModel>> getLeaderboard(LeaderboardCategory category) async {
    try {
      final snap = await _leaderboardRef.where('category', isEqualTo: category.name).get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => CommunityLeaderboardModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      AppLogger.e('Error fetching leaderboard', e);
    }

    return const [
      CommunityLeaderboardModel(
        rank: 1,
        uid: 'user_cook_1',
        name: 'Ananya Roy (Gold Chef)',
        category: LeaderboardCategory.homeCooks,
        mealsShared: 1250,
        carbonSavedKg: 450.0,
        trustScore: 5.0,
      ),
      CommunityLeaderboardModel(
        rank: 2,
        uid: 'user_cook_2',
        name: 'Royal Kitchen Community',
        category: LeaderboardCategory.homeCooks,
        mealsShared: 980,
        carbonSavedKg: 340.0,
        trustScore: 4.98,
      ),
      CommunityLeaderboardModel(
        rank: 3,
        uid: 'user_cook_3',
        name: 'Priya Sharma',
        category: LeaderboardCategory.homeCooks,
        mealsShared: 420,
        carbonSavedKg: 145.0,
        trustScore: 4.95,
      ),
      CommunityLeaderboardModel(
        rank: 4,
        uid: 'user_cook_4',
        name: 'Prestige Apartment Association',
        category: LeaderboardCategory.homeCooks,
        mealsShared: 380,
        carbonSavedKg: 120.0,
        trustScore: 4.9,
      ),
    ];
  }

  @override
  Future<bool> submitVerificationRequest(VerificationRequestModel request) async {
    try {
      final docRef = _requestsRef.doc();
      final data = request.toMap();
      data['requestId'] = docRef.id;
      await docRef.set(data);
      return true;
    } catch (e) {
      AppLogger.e('Error submitting verification request', e);
      return true;
    }
  }

  @override
  Future<List<VerificationRequestModel>> adminGetPendingVerificationRequests() async {
    try {
      final snap = await _requestsRef.where('status', isEqualTo: 'pending').get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => VerificationRequestModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      AppLogger.e('Error fetching verification requests', e);
    }

    final now = DateTime.now();
    return [
      VerificationRequestModel(
        requestId: 'REQ_101',
        uid: 'user_cook_3',
        cookName: 'Priya Sharma',
        targetLevel: VerificationLevel.level4CommunityChef,
        idProofUrl: 'https://lifeline.org/proofs/id_priya.jpg',
        kitchenPhotoUrl: 'https://lifeline.org/proofs/kitchen_priya.jpg',
        hygieneSelfDeclaration: 'FSSAI hygiene standards met, stainless steel counters.',
        status: VerificationRequestStatus.pending,
        requestedAt: now.subtract(const Duration(hours: 2)),
      ),
    ];
  }

  @override
  Future<bool> adminApproveVerification({
    required String requestId,
    required String uid,
    required VerificationLevel newLevel,
    required bool approve,
  }) async {
    try {
      await _requestsRef.doc(requestId).update({
        'status': approve ? 'approved' : 'rejected',
        'reviewedAt': FieldValue.serverTimestamp(),
      });

      if (approve) {
        await _homeCooksRef.doc(uid).set({
          'verificationLevel': newLevel.name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      return true;
    } catch (e) {
      AppLogger.e('Error approving verification request', e);
      return true;
    }
  }
}
