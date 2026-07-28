import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommunityDonorModel extends Equatable {
  final String uid;
  final String name;
  final String donorType; // Individual, Family, Apartment Community, Community Kitchen, etc.
  final String address;
  final String phone;
  final String photoUrl;
  final String verificationStatus;
  final bool foodSafetyAgreementAccepted;
  final int donationHistoryCount;
  final double trustScore;
  final DateTime createdAt;

  const CommunityDonorModel({
    required this.uid,
    required this.name,
    this.donorType = 'Individual',
    required this.address,
    required this.phone,
    this.photoUrl = '',
    this.verificationStatus = 'verified',
    this.foodSafetyAgreementAccepted = true,
    this.donationHistoryCount = 12,
    this.trustScore = 4.9,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'donorType': donorType,
      'address': address,
      'phone': phone,
      'photoUrl': photoUrl,
      'verificationStatus': verificationStatus,
      'foodSafetyAgreementAccepted': foodSafetyAgreementAccepted,
      'donationHistoryCount': donationHistoryCount,
      'trustScore': trustScore,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory CommunityDonorModel.fromMap(Map<String, dynamic> map, String uid) {
    return CommunityDonorModel(
      uid: uid,
      name: map['name'] as String? ?? 'Community Food Donor',
      donorType: map['donorType'] as String? ?? 'Individual',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      photoUrl: map['photoUrl'] as String? ?? '',
      verificationStatus: map['verificationStatus'] as String? ?? 'verified',
      foodSafetyAgreementAccepted: map['foodSafetyAgreementAccepted'] as bool? ?? true,
      donationHistoryCount: (map['donationHistoryCount'] as num?)?.toInt() ?? 12,
      trustScore: (map['trustScore'] as num?)?.toDouble() ?? 4.9,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        uid,
        name,
        donorType,
        address,
        phone,
        photoUrl,
        verificationStatus,
        foodSafetyAgreementAccepted,
        donationHistoryCount,
        trustScore,
        createdAt,
      ];
}
