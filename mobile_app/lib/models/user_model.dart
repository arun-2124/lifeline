import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // Donor, NGO, Volunteer, Delivery Partner, Beneficiary, Community Home Cook, Admin
  final String verificationStatus; // pending, verified, rejected
  final String accountStatus; // PENDING_ONBOARDING, PENDING_VERIFICATION, ACTIVE, SUSPENDED
  final bool acceptedTerms;
  final bool acceptedFoodSafetyAgreement;
  final DateTime? termsAcceptedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final String? photoUrl;
  final String? fcmToken;
  final double trustScore;

  // Phase 3 Profile & Reputation Fields
  final String? bio;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final double reputationScore;
  final double foodSafetyScore;
  final double completionRate;
  final double cancellationRate;
  final int responseTimeMinutes;
  final int verificationLevel; // Level 1 (Community Member) to Level 5 (Lifeline Champion)
  final List<String> unlockedBadges;
  final bool notificationsEnabled;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.verificationStatus = 'pending',
    this.accountStatus = 'ACTIVE',
    this.acceptedTerms = true,
    this.acceptedFoodSafetyAgreement = true,
    this.termsAcceptedAt,
    required this.createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.photoUrl,
    this.fcmToken,
    this.trustScore = 5.0,
    this.bio = 'Lifeline Community Member',
    this.address = '',
    this.city = 'Bengaluru',
    this.state = 'Karnataka',
    this.country = 'India',
    this.reputationScore = 98.5,
    this.foodSafetyScore = 99.0,
    this.completionRate = 99.5,
    this.cancellationRate = 0.5,
    this.responseTimeMinutes = 8,
    this.verificationLevel = 1,
    this.unlockedBadges = const ['🌱 First Donation', '⭐ 5-Star Member'],
    this.notificationsEnabled = true,
  });

  static String getVerificationLevelName(int level) {
    switch (level) {
      case 2:
        return 'Level 2: Verified User';
      case 3:
        return 'Level 3: Trusted Member';
      case 4:
        return 'Level 4: Verified Organization';
      case 5:
        return 'Level 5: Lifeline Champion';
      case 1:
      default:
        return 'Level 1: Community Member';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'verificationStatus': verificationStatus,
      'accountStatus': accountStatus,
      'acceptedTerms': acceptedTerms,
      'acceptedFoodSafetyAgreement': acceptedFoodSafetyAgreement,
      'termsAcceptedAt': termsAcceptedAt != null ? Timestamp.fromDate(termsAcceptedAt!) : FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'isEmailVerified': isEmailVerified,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
      'trustScore': trustScore,
      'bio': bio,
      'address': address,
      'city': city,
      'state': state,
      'country': country,
      'reputationScore': reputationScore,
      'foodSafetyScore': foodSafetyScore,
      'completionRate': completionRate,
      'cancellationRate': cancellationRate,
      'responseTimeMinutes': responseTimeMinutes,
      'verificationLevel': verificationLevel,
      'unlockedBadges': unlockedBadges,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (bio != null) 'bio': bio,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      'notificationsEnabled': notificationsEnabled,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      fullName: map['fullName'] as String? ?? map['displayName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      role: map['role'] as String? ?? 'Donor',
      verificationStatus: map['verificationStatus'] as String? ?? 'pending',
      accountStatus: map['accountStatus'] as String? ?? 'ACTIVE',
      acceptedTerms: map['acceptedTerms'] as bool? ?? true,
      acceptedFoodSafetyAgreement: map['acceptedFoodSafetyAgreement'] as bool? ?? true,
      termsAcceptedAt: map['termsAcceptedAt'] != null ? _parseDateTime(map['termsAcceptedAt']) : null,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? _parseDateTime(map['updatedAt']) : null,
      isEmailVerified: map['isEmailVerified'] as bool? ?? map['emailVerified'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
      fcmToken: map['fcmToken'] as String?,
      trustScore: (map['trustScore'] as num?)?.toDouble() ?? 5.0,
      bio: map['bio'] as String? ?? 'Lifeline Community Member',
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? 'Bengaluru',
      state: map['state'] as String? ?? 'Karnataka',
      country: map['country'] as String? ?? 'India',
      reputationScore: (map['reputationScore'] as num?)?.toDouble() ?? 98.5,
      foodSafetyScore: (map['foodSafetyScore'] as num?)?.toDouble() ?? 99.0,
      completionRate: (map['completionRate'] as num?)?.toDouble() ?? 99.5,
      cancellationRate: (map['cancellationRate'] as num?)?.toDouble() ?? 0.5,
      responseTimeMinutes: (map['responseTimeMinutes'] as num?)?.toInt() ?? 8,
      verificationLevel: (map['verificationLevel'] as num?)?.toInt() ?? 1,
      unlockedBadges: map['unlockedBadges'] != null
          ? List<String>.from(map['unlockedBadges'] as List)
          : const ['🌱 First Donation', '⭐ 5-Star Member'],
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? role,
    String? verificationStatus,
    String? accountStatus,
    bool? acceptedTerms,
    bool? acceptedFoodSafetyAgreement,
    DateTime? termsAcceptedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? photoUrl,
    String? fcmToken,
    double? trustScore,
    String? bio,
    String? address,
    String? city,
    String? state,
    String? country,
    double? reputationScore,
    double? foodSafetyScore,
    double? completionRate,
    double? cancellationRate,
    int? responseTimeMinutes,
    int? verificationLevel,
    List<String>? unlockedBadges,
    bool? notificationsEnabled,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      accountStatus: accountStatus ?? this.accountStatus,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      acceptedFoodSafetyAgreement: acceptedFoodSafetyAgreement ?? this.acceptedFoodSafetyAgreement,
      termsAcceptedAt: termsAcceptedAt ?? this.termsAcceptedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
      trustScore: trustScore ?? this.trustScore,
      bio: bio ?? this.bio,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      reputationScore: reputationScore ?? this.reputationScore,
      foodSafetyScore: foodSafetyScore ?? this.foodSafetyScore,
      completionRate: completionRate ?? this.completionRate,
      cancellationRate: cancellationRate ?? this.cancellationRate,
      responseTimeMinutes: responseTimeMinutes ?? this.responseTimeMinutes,
      verificationLevel: verificationLevel ?? this.verificationLevel,
      unlockedBadges: unlockedBadges ?? this.unlockedBadges,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        fullName,
        email,
        phoneNumber,
        role,
        verificationStatus,
        accountStatus,
        acceptedTerms,
        acceptedFoodSafetyAgreement,
        termsAcceptedAt,
        createdAt,
        updatedAt,
        isEmailVerified,
        photoUrl,
        fcmToken,
        trustScore,
        bio,
        address,
        city,
        state,
        country,
        reputationScore,
        foodSafetyScore,
        completionRate,
        cancellationRate,
        responseTimeMinutes,
        verificationLevel,
        unlockedBadges,
        notificationsEnabled,
      ];
}
