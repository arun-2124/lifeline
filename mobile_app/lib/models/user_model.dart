import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role; // Donor, NGO, Volunteer, Delivery Partner, Beneficiary, Admin
  final String verificationStatus; // pending, verified, rejected
  final String accountStatus; // PENDING_ONBOARDING, PENDING_VERIFICATION, ACTIVE, SUSPENDED
  final DateTime createdAt;
  final bool isEmailVerified;
  final String? photoUrl;
  final String? fcmToken;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    this.verificationStatus = 'pending',
    this.accountStatus = 'ACTIVE',
    required this.createdAt,
    this.isEmailVerified = false,
    this.photoUrl,
    this.fcmToken,
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
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'photoUrl': photoUrl,
      'fcmToken': fcmToken,
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
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      photoUrl: map['photoUrl'] as String?,
      fcmToken: map['fcmToken'] as String?,
    );
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? role,
    String? verificationStatus,
    String? accountStatus,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? photoUrl,
    String? fcmToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      accountStatus: accountStatus ?? this.accountStatus,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      fcmToken: fcmToken ?? this.fcmToken,
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
        createdAt,
        isEmailVerified,
        photoUrl,
        fcmToken,
      ];
}
