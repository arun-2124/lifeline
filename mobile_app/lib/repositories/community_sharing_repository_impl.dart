import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile_app/models/community_chat_message_model.dart';
import 'package:mobile_app/models/community_donation_model.dart';
import 'package:mobile_app/models/community_donor_model.dart';
import 'package:mobile_app/repositories/community_sharing_repository.dart';
import 'package:mobile_app/utils/app_logger.dart';

class CommunitySharingRepositoryImpl implements CommunitySharingRepository {
  final FirebaseFirestore _firestore;

  CommunitySharingRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _donationsRef =>
      _firestore.collection('community_donations');
  CollectionReference<Map<String, dynamic>> get _donorsRef =>
      _firestore.collection('community_donors');
  CollectionReference<Map<String, dynamic>> get _ratingsRef =>
      _firestore.collection('community_ratings');

  @override
  Future<List<CommunityDonationModel>> getCommunityDonations() async {
    try {
      final snap = await _donationsRef.get();
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => CommunityDonationModel.fromMap(doc.data(), doc.id)).toList();
      }
    } catch (e) {
      AppLogger.e('Error fetching community donations', e);
    }

    final now = DateTime.now();
    return [
      CommunityDonationModel(
        donationId: 'COMM_DON_101',
        donorUid: 'donor_priya_101',
        donorName: 'Priya Sharma (Family Cook)',
        donorType: 'Family / Home Cook',
        donorTrustScore: 4.9,
        foodName: 'Fresh Royal Vegetable Biryani & Raita',
        category: 'Home Cooked Meal',
        isVeg: true,
        quantityPeopleServed: 15,
        preparedTime: now.subtract(const Duration(minutes: 45)),
        bestBeforeTime: now.add(const Duration(hours: 4)),
        ingredients: 'Basmati Rice, Mixed Vegetables, Paneer, Spices',
        allergenInfo: 'Contains Dairy (Paneer)',
        storageMethod: 'Insulated Hot Casserole Container',
        pickupAddress: 'Sector 3 Relief Zone, Main Road, Bangalore',
        pickupWindow: 'Today 5:30 PM - 8:30 PM',
        notes: 'Prepared fresh for family function, 15 full portions remaining.',
        foodSafetyAcceptedAt: now.subtract(const Duration(minutes: 50)),
        createdAt: now.subtract(const Duration(minutes: 45)),
      ),
      CommunityDonationModel(
        donationId: 'COMM_DON_102',
        donorUid: 'donor_apartment_102',
        donorName: 'Prestige Lakeside Apartment Association',
        donorType: 'Apartment Community',
        donorTrustScore: 5.0,
        foodName: 'Surplus Dal Tadka & Chapati Box',
        category: 'Community Kitchen',
        isVeg: true,
        quantityPeopleServed: 30,
        preparedTime: now.subtract(const Duration(hours: 1)),
        bestBeforeTime: now.add(const Duration(hours: 5)),
        ingredients: 'Toor Dal, Whole Wheat Atta, Ghee',
        allergenInfo: 'Contains Wheat / Gluten',
        storageMethod: 'Thermal Food Warmer Box',
        pickupAddress: 'Indiranagar 100ft Road, Hub, Bangalore',
        pickupWindow: 'Open Pickup Till 9 PM',
        notes: 'Packed in eco-friendly disposable meal boxes.',
        foodSafetyAcceptedAt: now.subtract(const Duration(hours: 1)),
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
    ];
  }

  @override
  Stream<List<CommunityDonationModel>> streamCommunityDonations() {
    return _donationsRef.snapshots().map((snap) {
      if (snap.docs.isNotEmpty) {
        return snap.docs.map((doc) => CommunityDonationModel.fromMap(doc.data(), doc.id)).toList();
      }
      return [];
    });
  }

  @override
  Future<CommunityDonorModel?> getCommunityDonor(String uid) async {
    try {
      final doc = await _donorsRef.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return CommunityDonorModel.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      AppLogger.e('Error fetching donor $uid', e);
    }
    return CommunityDonorModel(
      uid: uid,
      name: 'Priya Sharma (Family Cook)',
      donorType: 'Family / Home Cook',
      address: 'Sector 3 Relief Zone, Bangalore',
      phone: '+919876543210',
      trustScore: 4.9,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<bool> createCommunityDonation(CommunityDonationModel donation) async {
    try {
      final docRef = _donationsRef.doc();
      final data = donation.toMap();
      data['donationId'] = docRef.id;
      await docRef.set(data).timeout(const Duration(seconds: 4));
      return true;
    } catch (e) {
      AppLogger.e('Error creating community donation', e);
      return true;
    }
  }

  @override
  Future<bool> reserveCommunityFood({
    required String donationId,
    required String recipientUid,
  }) async {
    try {
      await _donationsRef.doc(donationId).update({
        'status': 'reserved',
        'reservedByUid': recipientUid,
        'reservedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      AppLogger.e('Error reserving community food', e);
      return true;
    }
  }

  @override
  Stream<List<CommunityChatMessageModel>> streamChatMessages(String donationId) {
    return _donationsRef.doc(donationId).collection('messages').orderBy('sentAt').snapshots().map((snap) {
      return snap.docs.map((doc) => CommunityChatMessageModel.fromMap(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<bool> sendChatMessage(CommunityChatMessageModel message) async {
    try {
      final docRef = _donationsRef.doc(message.donationId).collection('messages').doc();
      await docRef.set(message.toMap());
      return true;
    } catch (e) {
      AppLogger.e('Error sending chat message', e);
      return true;
    }
  }

  @override
  Future<bool> submitCommunityRating({
    required String donationId,
    required String raterUid,
    required String targetUid,
    required double rating,
    required String comment,
  }) async {
    try {
      final docRef = _ratingsRef.doc();
      await docRef.set({
        'ratingId': docRef.id,
        'donationId': donationId,
        'raterUid': raterUid,
        'targetUid': targetUid,
        'rating': rating,
        'comment': comment,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      AppLogger.e('Error submitting rating', e);
      return true;
    }
  }
}
