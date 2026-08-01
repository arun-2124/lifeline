import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DonationModel extends Equatable {
  final String donationId;
  final String donorId;
  final String donorName;
  final String donorType; // Commercial Donor, Home Cook, Restaurant, Hotel, Community Kitchen, NGO
  final double donorTrustScore;
  final int donorVerificationLevel;
  final String foodName;
  final String foodCategory; // Cooked Meal, Produce, Bakery, Dairy, Packaged, Beverages
  final String foodType; // Veg, Non-Veg
  final String cuisine;
  final double quantity;
  final String unit; // kg, packets, plates, liters, boxes
  final int numberOfMeals;
  final int peopleServed;
  final DateTime preparationTime;
  final DateTime expiryTime;
  final String storageMethod;
  final String? temperature;
  final String pickupAddress;
  final String? landmark;
  final double latitude;
  final double longitude;
  final String contactNumber;
  final String? preferredPickupTime;
  final String? specialInstructions;
  final List<String> imageUrls;
  final String status; // Draft, Submitted, Available, Reserved, Volunteer Assigned, Picked Up, In Transit, Delivered, Completed, Cancelled, Expired

  // Food Quality Safety Checklist
  final bool isFreshlyCooked;
  final bool isProperlyPacked;
  final bool isHygienicallyPrepared;
  final bool isProperlyStored;
  final bool isSafeForConsumption;

  // Logistics & Verification Tracking
  final String? qrCodeData;
  final String? assignedVolunteerId;
  final String? assignedVolunteerName;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DonationModel({
    required this.donationId,
    required this.donorId,
    required this.donorName,
    this.donorType = 'Commercial Donor',
    this.donorTrustScore = 5.0,
    this.donorVerificationLevel = 1,
    required this.foodName,
    required this.foodCategory,
    required this.foodType,
    this.cuisine = 'Indian',
    required this.quantity,
    required this.unit,
    required this.numberOfMeals,
    this.peopleServed = 50,
    required this.preparationTime,
    required this.expiryTime,
    this.storageMethod = 'Insulated Container',
    this.temperature = '65°C Hot',
    required this.pickupAddress,
    this.landmark,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
    this.preferredPickupTime,
    this.specialInstructions,
    this.imageUrls = const [],
    this.status = 'Available',
    this.isFreshlyCooked = true,
    this.isProperlyPacked = true,
    this.isHygienicallyPrepared = true,
    this.isProperlyStored = true,
    this.isSafeForConsumption = true,
    this.qrCodeData,
    this.assignedVolunteerId,
    this.assignedVolunteerName,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isChecklistComplete =>
      isFreshlyCooked &&
      isProperlyPacked &&
      isHygienicallyPrepared &&
      isProperlyStored &&
      isSafeForConsumption;

  Map<String, dynamic> toMap() {
    return {
      'donationId': donationId,
      'donorId': donorId,
      'donorName': donorName,
      'donorType': donorType,
      'donorTrustScore': donorTrustScore,
      'donorVerificationLevel': donorVerificationLevel,
      'foodName': foodName,
      'foodCategory': foodCategory,
      'foodType': foodType,
      'cuisine': cuisine,
      'quantity': quantity,
      'unit': unit,
      'numberOfMeals': numberOfMeals,
      'peopleServed': peopleServed,
      'preparationTime': Timestamp.fromDate(preparationTime),
      'expiryTime': Timestamp.fromDate(expiryTime),
      'storageMethod': storageMethod,
      'temperature': temperature,
      'pickupAddress': pickupAddress,
      'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'contactNumber': contactNumber,
      'preferredPickupTime': preferredPickupTime,
      'specialInstructions': specialInstructions,
      'imageUrls': imageUrls,
      'status': status,
      'isFreshlyCooked': isFreshlyCooked,
      'isProperlyPacked': isProperlyPacked,
      'isHygienicallyPrepared': isHygienicallyPrepared,
      'isProperlyStored': isProperlyStored,
      'isSafeForConsumption': isSafeForConsumption,
      'qrCodeData': qrCodeData,
      'assignedVolunteerId': assignedVolunteerId,
      'assignedVolunteerName': assignedVolunteerName,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory DonationModel.fromMap(Map<String, dynamic> map, String id) {
    return DonationModel(
      donationId: map['donationId'] as String? ?? id,
      donorId: map['donorId'] as String? ?? '',
      donorName: map['donorName'] as String? ?? 'Anonymous Donor',
      donorType: map['donorType'] as String? ?? 'Commercial Donor',
      donorTrustScore: (map['donorTrustScore'] as num?)?.toDouble() ?? 5.0,
      donorVerificationLevel: (map['donorVerificationLevel'] as num?)?.toInt() ?? 1,
      foodName: map['foodName'] as String? ?? 'Surplus Meal',
      foodCategory: map['foodCategory'] as String? ?? 'Cooked Meal',
      foodType: map['foodType'] as String? ?? 'Veg',
      cuisine: map['cuisine'] as String? ?? 'Indian',
      quantity: (map['quantity'] as num? ?? 0.0).toDouble(),
      unit: map['unit'] as String? ?? 'kg',
      numberOfMeals: (map['numberOfMeals'] as num?)?.toInt() ?? (map['quantity'] as num? ?? 1).toInt() * 2,
      peopleServed: (map['peopleServed'] as num?)?.toInt() ?? 50,
      preparationTime: _parseDateTime(map['preparationTime']),
      expiryTime: map['expiryTime'] != null
          ? _parseDateTime(map['expiryTime'])
          : DateTime.now().add(const Duration(hours: 4)),
      storageMethod: map['storageMethod'] as String? ?? 'Insulated Container',
      temperature: map['temperature'] as String? ?? '65°C Hot',
      pickupAddress: map['pickupAddress'] as String? ?? '',
      landmark: map['landmark'] as String?,
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
      contactNumber: map['contactNumber'] as String? ?? '',
      preferredPickupTime: map['preferredPickupTime'] as String?,
      specialInstructions: map['specialInstructions'] as String?,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      status: map['status'] as String? ?? 'Available',
      isFreshlyCooked: map['isFreshlyCooked'] as bool? ?? true,
      isProperlyPacked: map['isProperlyPacked'] as bool? ?? true,
      isHygienicallyPrepared: map['isHygienicallyPrepared'] as bool? ?? true,
      isProperlyStored: map['isProperlyStored'] as bool? ?? true,
      isSafeForConsumption: map['isSafeForConsumption'] as bool? ?? true,
      qrCodeData: map['qrCodeData'] as String?,
      assignedVolunteerId: map['assignedVolunteerId'] as String?,
      assignedVolunteerName: map['assignedVolunteerName'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  DonationModel copyWith({
    String? donationId,
    String? donorId,
    String? donorName,
    String? donorType,
    double? donorTrustScore,
    int? donorVerificationLevel,
    String? foodName,
    String? foodCategory,
    String? foodType,
    String? cuisine,
    double? quantity,
    String? unit,
    int? numberOfMeals,
    int? peopleServed,
    DateTime? preparationTime,
    DateTime? expiryTime,
    String? storageMethod,
    String? temperature,
    String? pickupAddress,
    String? landmark,
    double? latitude,
    double? longitude,
    String? contactNumber,
    String? preferredPickupTime,
    String? specialInstructions,
    List<String>? imageUrls,
    String? status,
    bool? isFreshlyCooked,
    bool? isProperlyPacked,
    bool? isHygienicallyPrepared,
    bool? isProperlyStored,
    bool? isSafeForConsumption,
    String? qrCodeData,
    String? assignedVolunteerId,
    String? assignedVolunteerName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonationModel(
      donationId: donationId ?? this.donationId,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donorType: donorType ?? this.donorType,
      donorTrustScore: donorTrustScore ?? this.donorTrustScore,
      donorVerificationLevel: donorVerificationLevel ?? this.donorVerificationLevel,
      foodName: foodName ?? this.foodName,
      foodCategory: foodCategory ?? this.foodCategory,
      foodType: foodType ?? this.foodType,
      cuisine: cuisine ?? this.cuisine,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      numberOfMeals: numberOfMeals ?? this.numberOfMeals,
      peopleServed: peopleServed ?? this.peopleServed,
      preparationTime: preparationTime ?? this.preparationTime,
      expiryTime: expiryTime ?? this.expiryTime,
      storageMethod: storageMethod ?? this.storageMethod,
      temperature: temperature ?? this.temperature,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      landmark: landmark ?? this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactNumber: contactNumber ?? this.contactNumber,
      preferredPickupTime: preferredPickupTime ?? this.preferredPickupTime,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      isFreshlyCooked: isFreshlyCooked ?? this.isFreshlyCooked,
      isProperlyPacked: isProperlyPacked ?? this.isProperlyPacked,
      isHygienicallyPrepared: isHygienicallyPrepared ?? this.isHygienicallyPrepared,
      isProperlyStored: isProperlyStored ?? this.isProperlyStored,
      isSafeForConsumption: isSafeForConsumption ?? this.isSafeForConsumption,
      qrCodeData: qrCodeData ?? this.qrCodeData,
      assignedVolunteerId: assignedVolunteerId ?? this.assignedVolunteerId,
      assignedVolunteerName: assignedVolunteerName ?? this.assignedVolunteerName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        donationId,
        donorId,
        donorName,
        donorType,
        donorTrustScore,
        donorVerificationLevel,
        foodName,
        foodCategory,
        foodType,
        cuisine,
        quantity,
        unit,
        numberOfMeals,
        peopleServed,
        preparationTime,
        expiryTime,
        storageMethod,
        temperature,
        pickupAddress,
        landmark,
        latitude,
        longitude,
        contactNumber,
        preferredPickupTime,
        specialInstructions,
        imageUrls,
        status,
        isFreshlyCooked,
        isProperlyPacked,
        isHygienicallyPrepared,
        isProperlyStored,
        isSafeForConsumption,
        qrCodeData,
        assignedVolunteerId,
        assignedVolunteerName,
        createdAt,
        updatedAt,
      ];
}
