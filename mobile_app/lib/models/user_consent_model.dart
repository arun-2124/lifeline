import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class UserConsentModel extends Equatable {
  static const String currentTermsVersion = '1.0';
  static const String currentPrivacyVersion = '1.0';
  static const String currentFoodSafetyVersion = '1.0';
  static const String currentCommunityVersion = '1.0';

  final bool acceptedTerms;
  final bool acceptedPrivacyPolicy;
  final bool acceptedCommunityGuidelines;
  final bool acceptedFoodSafetyAgreement;
  final String termsVersion;
  final String privacyVersion;
  final String communityVersion;
  final String foodSafetyVersion;
  final DateTime acceptedAt;
  final String acceptedDevice;

  const UserConsentModel({
    required this.acceptedTerms,
    required this.acceptedPrivacyPolicy,
    required this.acceptedCommunityGuidelines,
    required this.acceptedFoodSafetyAgreement,
    this.termsVersion = currentTermsVersion,
    this.privacyVersion = currentPrivacyVersion,
    this.communityVersion = currentCommunityVersion,
    this.foodSafetyVersion = currentFoodSafetyVersion,
    required this.acceptedAt,
    this.acceptedDevice = 'Android App',
  });

  Map<String, dynamic> toMap() {
    return {
      'acceptedTerms': acceptedTerms,
      'acceptedPrivacyPolicy': acceptedPrivacyPolicy,
      'acceptedCommunityGuidelines': acceptedCommunityGuidelines,
      'acceptedFoodSafetyAgreement': acceptedFoodSafetyAgreement,
      'termsVersion': termsVersion,
      'privacyVersion': privacyVersion,
      'communityVersion': communityVersion,
      'foodSafetyVersion': foodSafetyVersion,
      'acceptedAt': Timestamp.fromDate(acceptedAt),
      'acceptedDevice': acceptedDevice,
    };
  }

  factory UserConsentModel.fromMap(Map<String, dynamic> map) {
    return UserConsentModel(
      acceptedTerms: map['acceptedTerms'] as bool? ?? false,
      acceptedPrivacyPolicy: map['acceptedPrivacyPolicy'] as bool? ?? false,
      acceptedCommunityGuidelines: map['acceptedCommunityGuidelines'] as bool? ?? false,
      acceptedFoodSafetyAgreement: map['acceptedFoodSafetyAgreement'] as bool? ?? false,
      termsVersion: map['termsVersion'] as String? ?? currentTermsVersion,
      privacyVersion: map['privacyVersion'] as String? ?? currentPrivacyVersion,
      communityVersion: map['communityVersion'] as String? ?? currentCommunityVersion,
      foodSafetyVersion: map['foodSafetyVersion'] as String? ?? currentFoodSafetyVersion,
      acceptedAt: map['acceptedAt'] is Timestamp
          ? (map['acceptedAt'] as Timestamp).toDate()
          : DateTime.now(),
      acceptedDevice: map['acceptedDevice'] as String? ?? 'Android App',
    );
  }

  bool isVersionUpToDateForRole(String role) {
    final cleanRole = role.trim().toLowerCase();
    final requiresFoodSafety = cleanRole == 'donor' || cleanRole == 'community home cook' || cleanRole == 'home cook';
    final requiresCommunity = cleanRole != 'beneficiary' && cleanRole != 'admin';

    if (!acceptedTerms || termsVersion != currentTermsVersion) return false;
    if (!acceptedPrivacyPolicy || privacyVersion != currentPrivacyVersion) return false;
    if (requiresCommunity && (!acceptedCommunityGuidelines || communityVersion != currentCommunityVersion)) return false;
    if (requiresFoodSafety && (!acceptedFoodSafetyAgreement || foodSafetyVersion != currentFoodSafetyVersion)) return false;

    return true;
  }

  @override
  List<Object?> get props => [
        acceptedTerms,
        acceptedPrivacyPolicy,
        acceptedCommunityGuidelines,
        acceptedFoodSafetyAgreement,
        termsVersion,
        privacyVersion,
        communityVersion,
        foodSafetyVersion,
        acceptedAt,
        acceptedDevice,
      ];
}
