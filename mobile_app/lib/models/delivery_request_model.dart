import 'package:equatable/equatable.dart';

class DeliveryRequestModel extends Equatable {
  final String deliveryId;
  final String donationId;
  final String requestId;
  final String donorId;
  final String donorName;
  final String donorPhone;
  final String pickupAddress;
  final double pickupLat;
  final double pickupLng;
  final String ngoId;
  final String ngoName;
  final String ngoPhone;
  final String destinationAddress;
  final double destLat;
  final double destLng;
  final String foodName;
  final double quantity;
  final String unit;
  final int numberOfMeals;
  final String? volunteerId;
  final String? volunteerName;
  final String status; // Waiting for Volunteer, Volunteer Assigned, Pickup Started, Picked Up, On the Way, Delivered, Completed, Cancelled
  final double estimatedDistanceKm;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryRequestModel({
    required this.deliveryId,
    required this.donationId,
    required this.requestId,
    required this.donorId,
    required this.donorName,
    required this.donorPhone,
    required this.pickupAddress,
    required this.pickupLat,
    required this.pickupLng,
    required this.ngoId,
    required this.ngoName,
    required this.ngoPhone,
    required this.destinationAddress,
    required this.destLat,
    required this.destLng,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.numberOfMeals,
    this.volunteerId,
    this.volunteerName,
    this.status = 'Waiting for Volunteer',
    this.estimatedDistanceKm = 3.5,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'deliveryId': deliveryId,
      'donationId': donationId,
      'requestId': requestId,
      'donorId': donorId,
      'donorName': donorName,
      'donorPhone': donorPhone,
      'pickupAddress': pickupAddress,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'ngoPhone': ngoPhone,
      'destinationAddress': destinationAddress,
      'destLat': destLat,
      'destLng': destLng,
      'foodName': foodName,
      'quantity': quantity,
      'unit': unit,
      'numberOfMeals': numberOfMeals,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'status': status,
      'estimatedDistanceKm': estimatedDistanceKm,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory DeliveryRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryRequestModel(
      deliveryId: map['deliveryId'] as String? ?? id,
      donationId: map['donationId'] as String? ?? '',
      requestId: map['requestId'] as String? ?? '',
      donorId: map['donorId'] as String? ?? '',
      donorName: map['donorName'] as String? ?? 'Donor',
      donorPhone: map['donorPhone'] as String? ?? '',
      pickupAddress: map['pickupAddress'] as String? ?? '',
      pickupLat: (map['pickupLat'] as num? ?? 12.9716).toDouble(),
      pickupLng: (map['pickupLng'] as num? ?? 77.5946).toDouble(),
      ngoId: map['ngoId'] as String? ?? '',
      ngoName: map['ngoName'] as String? ?? 'NGO',
      ngoPhone: map['ngoPhone'] as String? ?? '',
      destinationAddress: map['destinationAddress'] as String? ?? map['pickupAddress'] as String? ?? '',
      destLat: (map['destLat'] as num? ?? 12.9750).toDouble(),
      destLng: (map['destLng'] as num? ?? 77.6000).toDouble(),
      foodName: map['foodName'] as String? ?? 'Surplus Food',
      quantity: (map['quantity'] as num? ?? 0.0).toDouble(),
      unit: map['unit'] as String? ?? 'kg',
      numberOfMeals: map['numberOfMeals'] as int? ?? 1,
      volunteerId: map['volunteerId'] as String?,
      volunteerName: map['volunteerName'] as String?,
      status: map['status'] as String? ?? 'Waiting for Volunteer',
      estimatedDistanceKm: (map['estimatedDistanceKm'] as num? ?? 3.5).toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  DeliveryRequestModel copyWith({
    String? deliveryId,
    String? donationId,
    String? requestId,
    String? donorId,
    String? donorName,
    String? donorPhone,
    String? pickupAddress,
    double? pickupLat,
    double? pickupLng,
    String? ngoId,
    String? ngoName,
    String? ngoPhone,
    String? destinationAddress,
    double? destLat,
    double? destLng,
    String? foodName,
    double? quantity,
    String? unit,
    int? numberOfMeals,
    String? volunteerId,
    String? volunteerName,
    String? status,
    double? estimatedDistanceKm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeliveryRequestModel(
      deliveryId: deliveryId ?? this.deliveryId,
      donationId: donationId ?? this.donationId,
      requestId: requestId ?? this.requestId,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      donorPhone: donorPhone ?? this.donorPhone,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      ngoId: ngoId ?? this.ngoId,
      ngoName: ngoName ?? this.ngoName,
      ngoPhone: ngoPhone ?? this.ngoPhone,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      destLat: destLat ?? this.destLat,
      destLng: destLng ?? this.destLng,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      numberOfMeals: numberOfMeals ?? this.numberOfMeals,
      volunteerId: volunteerId ?? this.volunteerId,
      volunteerName: volunteerName ?? this.volunteerName,
      status: status ?? this.status,
      estimatedDistanceKm: estimatedDistanceKm ?? this.estimatedDistanceKm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        deliveryId,
        donationId,
        requestId,
        donorId,
        donorName,
        donorPhone,
        pickupAddress,
        pickupLat,
        pickupLng,
        ngoId,
        ngoName,
        ngoPhone,
        destinationAddress,
        destLat,
        destLng,
        foodName,
        quantity,
        unit,
        numberOfMeals,
        volunteerId,
        volunteerName,
        status,
        estimatedDistanceKm,
        createdAt,
        updatedAt,
      ];
}
