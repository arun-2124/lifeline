import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum CommunityDonationStatus {
  available,
  reserved,
  delivered,
  expired,
}

class CommunityDonationModel extends Equatable {
  final String donationId;
  final String donorUid;
  final String donorName;
  final String donorType;
  final double donorTrustScore;
  final String foodName;
  final String category;
  final bool isVeg;
  final int quantityPeopleServed;
  final DateTime preparedTime;
  final DateTime bestBeforeTime;
  final String ingredients;
  final String allergenInfo;
  final String storageMethod;
  final String pickupAddress;
  final String pickupWindow;
  final List<String> images;
  final String notes;
  final CommunityDonationStatus status;
  final DateTime foodSafetyAcceptedAt;
  final DateTime createdAt;

  const CommunityDonationModel({
    required this.donationId,
    required this.donorUid,
    required this.donorName,
    this.donorType = 'Family / Home Cook',
    this.donorTrustScore = 4.9,
    required this.foodName,
    this.category = 'Home Cooked Meal',
    this.isVeg = true,
    required this.quantityPeopleServed,
    required this.preparedTime,
    required this.bestBeforeTime,
    required this.ingredients,
    this.allergenInfo = 'None',
    this.storageMethod = 'Insulated Hot Casserole Container',
    required this.pickupAddress,
    required this.pickupWindow,
    this.images = const [],
    this.notes = '',
    this.status = CommunityDonationStatus.available,
    required this.foodSafetyAcceptedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'donationId': donationId,
      'donorUid': donorUid,
      'donorName': donorName,
      'donorType': donorType,
      'donorTrustScore': donorTrustScore,
      'foodName': foodName,
      'category': category,
      'isVeg': isVeg,
      'quantityPeopleServed': quantityPeopleServed,
      'preparedTime': Timestamp.fromDate(preparedTime),
      'bestBeforeTime': Timestamp.fromDate(bestBeforeTime),
      'ingredients': ingredients,
      'allergenInfo': allergenInfo,
      'storageMethod': storageMethod,
      'pickupAddress': pickupAddress,
      'pickupWindow': pickupWindow,
      'images': images,
      'notes': notes,
      'status': status.name,
      'foodSafetyAcceptedAt': Timestamp.fromDate(foodSafetyAcceptedAt),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory CommunityDonationModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityDonationModel(
      donationId: id,
      donorUid: map['donorUid'] as String? ?? '',
      donorName: map['donorName'] as String? ?? 'Community Donor',
      donorType: map['donorType'] as String? ?? 'Family / Home Cook',
      donorTrustScore: (map['donorTrustScore'] as num?)?.toDouble() ?? 4.9,
      foodName: map['foodName'] as String? ?? 'Fresh Home Cooked Meal',
      category: map['category'] as String? ?? 'Home Cooked Meal',
      isVeg: map['isVeg'] as bool? ?? true,
      quantityPeopleServed: (map['quantityPeopleServed'] as num?)?.toInt() ?? 10,
      preparedTime: map['preparedTime'] is Timestamp
          ? (map['preparedTime'] as Timestamp).toDate()
          : DateTime.now().subtract(const Duration(hours: 1)),
      bestBeforeTime: map['bestBeforeTime'] is Timestamp
          ? (map['bestBeforeTime'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(hours: 4)),
      ingredients: map['ingredients'] as String? ?? 'Rice, Lentils, Spices',
      allergenInfo: map['allergenInfo'] as String? ?? 'None',
      storageMethod: map['storageMethod'] as String? ?? 'Insulated Casserole',
      pickupAddress: map['pickupAddress'] as String? ?? 'Bangalore Relief Zone',
      pickupWindow: map['pickupWindow'] as String? ?? 'Today 5:00 PM - 8:00 PM',
      images: (map['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      notes: map['notes'] as String? ?? '',
      status: _parseStatus(map['status']),
      foodSafetyAcceptedAt: map['foodSafetyAcceptedAt'] is Timestamp
          ? (map['foodSafetyAcceptedAt'] as Timestamp).toDate()
          : DateTime.now(),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  static CommunityDonationStatus _parseStatus(dynamic val) {
    if (val == 'reserved' || val == 'RESERVED') return CommunityDonationStatus.reserved;
    if (val == 'delivered' || val == 'DELIVERED') return CommunityDonationStatus.delivered;
    if (val == 'expired' || val == 'EXPIRED') return CommunityDonationStatus.expired;
    return CommunityDonationStatus.available;
  }

  @override
  List<Object?> get props => [
        donationId,
        donorUid,
        donorName,
        donorType,
        donorTrustScore,
        foodName,
        category,
        isVeg,
        quantityPeopleServed,
        preparedTime,
        bestBeforeTime,
        ingredients,
        allergenInfo,
        storageMethod,
        pickupAddress,
        pickupWindow,
        images,
        notes,
        status,
        foodSafetyAcceptedAt,
        createdAt,
      ];
}
