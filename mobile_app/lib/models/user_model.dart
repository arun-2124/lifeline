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
  });

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
    };
  }

  Map<String, dynamic> toUpdateMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'updatedAt': FieldValue.serverTimestamp(),
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (fcmToken != null) 'fcmToken': fcmToken,
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
      ];
}
