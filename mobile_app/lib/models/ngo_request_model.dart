import 'package:equatable/equatable.dart';

class NgoRequestModel extends Equatable {
  final String requestId;
  final String donationId;
  final String ngoId;
  final String ngoName;
  final String donorId;
  final String donorName;
  final String foodName;
  final double quantity;
  final String unit;
  final int numberOfMeals;
  final String pickupAddress;
  final double latitude;
  final double longitude;
  final String status; // Pending, VolunteerAssigned, PickedUp, Delivered, Completed, Cancelled
  final DateTime requestedAt;
  final String? notes;

  const NgoRequestModel({
    required this.requestId,
    required this.donationId,
    required this.ngoId,
    required this.ngoName,
    required this.donorId,
    required this.donorName,
    required this.foodName,
    required this.quantity,
    required this.unit,
    required this.numberOfMeals,
    required this.pickupAddress,
    required this.latitude,
    required this.longitude,
    this.status = 'Pending',
    required this.requestedAt,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'donationId': donationId,
      'ngoId': ngoId,
      'ngoName': ngoName,
      'donorId': donorId,
      'donorName': donorName,
      'foodName': foodName,
      'quantity': quantity,
      'unit': unit,
      'numberOfMeals': numberOfMeals,
      'pickupAddress': pickupAddress,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'requestedAt': requestedAt.toIso8601String(),
      'notes': notes,
    };
  }

  factory NgoRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return NgoRequestModel(
      requestId: map['requestId'] as String? ?? id,
      donationId: map['donationId'] as String? ?? '',
      ngoId: map['ngoId'] as String? ?? '',
      ngoName: map['ngoName'] as String? ?? 'Partner NGO',
      donorId: map['donorId'] as String? ?? '',
      donorName: map['donorName'] as String? ?? 'Donor',
      foodName: map['foodName'] as String? ?? '',
      quantity: (map['quantity'] as num? ?? 0.0).toDouble(),
      unit: map['unit'] as String? ?? 'kg',
      numberOfMeals: map['numberOfMeals'] as int? ?? 1,
      pickupAddress: map['pickupAddress'] as String? ?? '',
      latitude: (map['latitude'] as num? ?? 0.0).toDouble(),
      longitude: (map['longitude'] as num? ?? 0.0).toDouble(),
      status: map['status'] as String? ?? 'Pending',
      requestedAt: map['requestedAt'] != null
          ? DateTime.tryParse(map['requestedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      notes: map['notes'] as String?,
    );
  }

  NgoRequestModel copyWith({
    String? requestId,
    String? donationId,
    String? ngoId,
    String? ngoName,
    String? donorId,
    String? donorName,
    String? foodName,
    double? quantity,
    String? unit,
    int? numberOfMeals,
    String? pickupAddress,
    double? latitude,
    double? longitude,
    String? status,
    DateTime? requestedAt,
    String? notes,
  }) {
    return NgoRequestModel(
      requestId: requestId ?? this.requestId,
      donationId: donationId ?? this.donationId,
      ngoId: ngoId ?? this.ngoId,
      ngoName: ngoName ?? this.ngoName,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      numberOfMeals: numberOfMeals ?? this.numberOfMeals,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        requestId,
        donationId,
        ngoId,
        ngoName,
        donorId,
        donorName,
        foodName,
        quantity,
        unit,
        numberOfMeals,
        pickupAddress,
        latitude,
        longitude,
        status,
        requestedAt,
        notes,
      ];
}
