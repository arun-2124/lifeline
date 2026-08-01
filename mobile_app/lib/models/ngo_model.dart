import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class NgoModel extends Equatable {
  final String ngoId;
  final String ngoName;
  final String registrationNumber;
  final String ngoType; // Shelter Home, Orphanage, Food Bank, Relief Center, Community Kitchen
  final String contactPerson;
  final String email;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final String operatingHours;
  final String? website;
  final int numberOfBeneficiaries;
  final int dailyMealCapacity;
  final double storageCapacityKg;
  final List<String> foodCategoriesAccepted;
  final String verificationStatus; // pending, verified, rejected
  final double trustScore;
  final String? profileImageUrl;

  const NgoModel({
    required this.ngoId,
    required this.ngoName,
    required this.registrationNumber,
    this.ngoType = 'Food Bank & Relief Center',
    required this.contactPerson,
    required this.email,
    required this.phone,
    required this.address,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.operatingHours = '08:00 AM - 08:00 PM',
    this.website,
    this.numberOfBeneficiaries = 450,
    this.dailyMealCapacity = 800,
    this.storageCapacityKg = 500.0,
    this.foodCategoriesAccepted = const ['Cooked Meal', 'Produce', 'Bakery', 'Dairy', 'Packaged'],
    this.verificationStatus = 'verified',
    this.trustScore = 4.95,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'ngoId': ngoId,
      'ngoName': ngoName,
      'registrationNumber': registrationNumber,
      'ngoType': ngoType,
      'contactPerson': contactPerson,
      'email': email,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'operatingHours': operatingHours,
      'website': website,
      'numberOfBeneficiaries': numberOfBeneficiaries,
      'dailyMealCapacity': dailyMealCapacity,
      'storageCapacityKg': storageCapacityKg,
      'foodCategoriesAccepted': foodCategoriesAccepted,
      'verificationStatus': verificationStatus,
      'trustScore': trustScore,
      'profileImageUrl': profileImageUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory NgoModel.fromMap(Map<String, dynamic> map, String id) {
    return NgoModel(
      ngoId: id,
      ngoName: map['ngoName'] as String? ?? 'Partner Food Bank',
      registrationNumber: map['registrationNumber'] as String? ?? 'REG/NGO/2026/884',
      ngoType: map['ngoType'] as String? ?? 'Food Bank & Relief Center',
      contactPerson: map['contactPerson'] as String? ?? 'Director',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      address: map['address'] as String? ?? 'Bengaluru, India',
      latitude: (map['latitude'] as num? ?? 12.9716).toDouble(),
      longitude: (map['longitude'] as num? ?? 77.5946).toDouble(),
      operatingHours: map['operatingHours'] as String? ?? '08:00 AM - 08:00 PM',
      website: map['website'] as String?,
      numberOfBeneficiaries: (map['numberOfBeneficiaries'] as num?)?.toInt() ?? 450,
      dailyMealCapacity: (map['dailyMealCapacity'] as num?)?.toInt() ?? 800,
      storageCapacityKg: (map['storageCapacityKg'] as num?)?.toDouble() ?? 500.0,
      foodCategoriesAccepted: map['foodCategoriesAccepted'] != null
          ? List<String>.from(map['foodCategoriesAccepted'] as List)
          : const ['Cooked Meal', 'Produce', 'Bakery', 'Dairy', 'Packaged'],
      verificationStatus: map['verificationStatus'] as String? ?? 'verified',
      trustScore: (map['trustScore'] as num?)?.toDouble() ?? 4.95,
      profileImageUrl: map['profileImageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        ngoId,
        ngoName,
        registrationNumber,
        ngoType,
        contactPerson,
        email,
        phone,
        address,
        latitude,
        longitude,
        operatingHours,
        website,
        numberOfBeneficiaries,
        dailyMealCapacity,
        storageCapacityKg,
        foodCategoriesAccepted,
        verificationStatus,
        trustScore,
        profileImageUrl,
      ];
}
