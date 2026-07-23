import 'package:equatable/equatable.dart';

class DonationModel extends Equatable {
  final String donationId;
  final String donorId;
  final String donorName;
  final String foodName;
  final String foodCategory; // cooked_meal, produce, bakery, dairy, packaged, beverages
  final String foodType; // Veg, Non-Veg
  final double quantity;
  final String unit; // kg, packets, plates, liters, boxes
  final int numberOfMeals;
  final DateTime preparationTime;
  final DateTime expiryTime;
  final String pickupAddress;
  final double latitude;
  final double longitude;
  final String contactNumber;
  final String? specialInstructions;
  final List<String> imageUrls;
  final String status; // Pending, Matched, Accepted, Picked Up, Delivered, Completed, Cancelled, Expired
  final DateTime createdAt;
  final DateTime updatedAt;

  const DonationModel({
    required this.donationId,
    required this.donorId,
    required this.donorName,
    required this.foodName,
    required this.foodCategory,
    required this.foodType,
    required this.quantity,
    required this.unit,
    required this.numberOfMeals,
    required this.preparationTime,
    required this.expiryTime,
    required this.pickupAddress,
    required this.latitude,
    required this.longitude,
    required this.contactNumber,
    this.specialInstructions,
    this.imageUrls = const [],
    this.status = 'Pending',
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'donationId': donationId,
      'donorId': donorId,
      'donorName': donorName,
      'foodName': foodName,
      'foodCategory': foodCategory,
      'foodType': foodType,
      'quantity': quantity,
      'unit': unit,
      'numberOfMeals': numberOfMeals,
      'preparationTime': preparationTime.toIso8601String(),
      'expiryTime': expiryTime.toIso8601String(),
      'pickupAddress': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'contactNumber': contactNumber,
      'specialInstructions': specialInstructions,
      'imageUrls': imageUrls,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DonationModel.fromMap(Map<String, dynamic> map, String id) {
    return DonationModel(
      donationId: map['donationId'] as String? ?? id,
      donorId: map['donorId'] as String? ?? '',
      donorName: map['donorName'] as String? ?? 'Anonymous Donor',
      foodName: map['foodName'] as String? ?? '',
      foodCategory: map['foodCategory'] as String? ?? 'cooked_meal',
      foodType: map['foodType'] as String? ?? 'Veg',
      quantity: (map['quantity'] as num? ?? 0.0).toDouble(),
      unit: map['unit'] as String? ?? 'kg',
      numberOfMeals: map['numberOfMeals'] as int? ?? (map['quantity'] as num? ?? 1).toInt() * 2,
      preparationTime: map['preparationTime'] != null
          ? DateTime.tryParse(map['preparationTime'] as String) ?? DateTime.now()
          : DateTime.now(),
      expiryTime: map['expiryTime'] != null
          ? DateTime.tryParse(map['expiryTime'] as String) ?? DateTime.now().add(const Duration(hours: 4))
          : DateTime.now().add(const Duration(hours: 4)),
      pickupAddress: map['pickupAddress'] as String? ?? '',
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
      contactNumber: map['contactNumber'] as String? ?? '',
      specialInstructions: map['specialInstructions'] as String?,
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      status: map['status'] as String? ?? 'Pending',
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  DonationModel copyWith({
    String? donationId,
    String? donorId,
    String? donorName,
    String? foodName,
    String? foodCategory,
    String? foodType,
    double? quantity,
    String? unit,
    int? numberOfMeals,
    DateTime? preparationTime,
    DateTime? expiryTime,
    String? pickupAddress,
    double? latitude,
    double? longitude,
    String? contactNumber,
    String? specialInstructions,
    List<String>? imageUrls,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DonationModel(
      donationId: donationId ?? this.donationId,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      foodName: foodName ?? this.foodName,
      foodCategory: foodCategory ?? this.foodCategory,
      foodType: foodType ?? this.foodType,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      numberOfMeals: numberOfMeals ?? this.numberOfMeals,
      preparationTime: preparationTime ?? this.preparationTime,
      expiryTime: expiryTime ?? this.expiryTime,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactNumber: contactNumber ?? this.contactNumber,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        donationId,
        donorId,
        donorName,
        foodName,
        foodCategory,
        foodType,
        quantity,
        unit,
        numberOfMeals,
        preparationTime,
        expiryTime,
        pickupAddress,
        latitude,
        longitude,
        contactNumber,
        specialInstructions,
        imageUrls,
        status,
        createdAt,
        updatedAt,
      ];
}
