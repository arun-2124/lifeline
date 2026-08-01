import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum VerificationLevel {
  level1CommunityDonor,
  level2VerifiedHomeCook,
  level3TrustedHomeCook,
  level4CommunityChef,
  level5GoldChef,
}

class HomeCookProfileModel extends Equatable {
  final String uid;
  final String name;
  final String donorType; // Individual, Family, Apartment Community, Community Kitchen, Religious Organization, Student Hostel, Small Events, NGOs
  final VerificationLevel verificationLevel;
  final double trustScore;
  final double foodSafetyRating;
  final double reliabilityScore;
  final int mealsShared;
  final int peopleHelped;
  final double completionRate;
  final int communityRank;
  final double carbonSavedKg;
  final double wastePreventedKg;
  final int volunteerHours;
  final List<String> unlockedBadges;
  final DateTime createdAt;

  const HomeCookProfileModel({
    required this.uid,
    required this.name,
    this.donorType = 'Family / Home Cook',
    this.verificationLevel = VerificationLevel.level2VerifiedHomeCook,
    this.trustScore = 4.9,
    this.foodSafetyRating = 4.95,
    this.reliabilityScore = 98.5,
    this.mealsShared = 340,
    this.peopleHelped = 280,
    this.completionRate = 99.0,
    this.communityRank = 4,
    this.carbonSavedKg = 85.5,
    this.wastePreventedKg = 120.0,
    this.volunteerHours = 45,
    this.unlockedBadges = const [
      '🥗 First Meal Shared',
      '🍲 Home Hero',
      '👨‍🍳 Verified Home Cook',
      '🏅 Trusted Chef',
      '⭐ Five-Star Cook',
      '🌱 Sustainability Champion',
    ],
    required this.createdAt,
  });

  static String formatLevelName(VerificationLevel level) {
    switch (level) {
      case VerificationLevel.level1CommunityDonor:
        return 'Level 1: Community Donor';
      case VerificationLevel.level2VerifiedHomeCook:
        return 'Level 2: Verified Home Cook';
      case VerificationLevel.level3TrustedHomeCook:
        return 'Level 3: Trusted Home Cook';
      case VerificationLevel.level4CommunityChef:
        return 'Level 4: Community Chef';
      case VerificationLevel.level5GoldChef:
        return 'Level 5: Lifeline Gold Chef';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'donorType': donorType,
      'verificationLevel': verificationLevel.name,
      'trustScore': trustScore,
      'foodSafetyRating': foodSafetyRating,
      'reliabilityScore': reliabilityScore,
      'mealsShared': mealsShared,
      'peopleHelped': peopleHelped,
      'completionRate': completionRate,
      'communityRank': communityRank,
      'carbonSavedKg': carbonSavedKg,
      'wastePreventedKg': wastePreventedKg,
      'volunteerHours': volunteerHours,
      'unlockedBadges': unlockedBadges,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory HomeCookProfileModel.fromMap(Map<String, dynamic> map, String uid) {
    return HomeCookProfileModel(
      uid: uid,
      name: map['name'] as String? ?? 'Verified Home Cook',
      donorType: map['donorType'] as String? ?? 'Family / Home Cook',
      verificationLevel: _parseLevel(map['verificationLevel']),
      trustScore: (map['trustScore'] as num?)?.toDouble() ?? 4.9,
      foodSafetyRating: (map['foodSafetyRating'] as num?)?.toDouble() ?? 4.95,
      reliabilityScore: (map['reliabilityScore'] as num?)?.toDouble() ?? 98.5,
      mealsShared: (map['mealsShared'] as num?)?.toInt() ?? 340,
      peopleHelped: (map['peopleHelped'] as num?)?.toInt() ?? 280,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 99.0,
      communityRank: (map['communityRank'] as num?)?.toInt() ?? 4,
      carbonSavedKg: (map['carbonSavedKg'] as num?)?.toDouble() ?? 85.5,
      wastePreventedKg: (map['wastePreventedKg'] as num?)?.toDouble() ?? 120.0,
      volunteerHours: (map['volunteerHours'] as num?)?.toInt() ?? 45,
      unlockedBadges: (map['unlockedBadges'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [
            '🥗 First Meal Shared',
            '🍲 Home Hero',
            '👨‍🍳 Verified Home Cook',
            '🏅 Trusted Chef',
            '⭐ Five-Star Cook',
            '🌱 Sustainability Champion',
          ],
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  static VerificationLevel _parseLevel(dynamic val) {
    if (val == 'level5GoldChef' || val == 'LEVEL_5_GOLD_CHEF') return VerificationLevel.level5GoldChef;
    if (val == 'level4CommunityChef' || val == 'LEVEL_4_COMMUNITY_CHEF') return VerificationLevel.level4CommunityChef;
    if (val == 'level3TrustedHomeCook' || val == 'LEVEL_3_TRUSTED_HOME_COOK') return VerificationLevel.level3TrustedHomeCook;
    if (val == 'level1CommunityDonor' || val == 'LEVEL_1_COMMUNITY_DONOR') return VerificationLevel.level1CommunityDonor;
    return VerificationLevel.level2VerifiedHomeCook;
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        donorType,
        verificationLevel,
        trustScore,
        foodSafetyRating,
        reliabilityScore,
        mealsShared,
        peopleHelped,
        completionRate,
        communityRank,
        carbonSavedKg,
        wastePreventedKg,
        volunteerHours,
        unlockedBadges,
        createdAt,
      ];
}
