import 'package:equatable/equatable.dart';

class TrackingModel extends Equatable {
  final String trackingId;
  final String donationId;
  final String deliveryId;
  final String volunteerId;
  final String volunteerName;
  final double currentLat;
  final double currentLng;
  final double speedKmh;
  final double heading;
  final DateTime lastUpdated;
  final int estimatedArrivalMinutes;
  final double distanceRemainingKm;

  const TrackingModel({
    required this.trackingId,
    required this.donationId,
    required this.deliveryId,
    required this.volunteerId,
    required this.volunteerName,
    required this.currentLat,
    required this.currentLng,
    this.speedKmh = 25.0,
    this.heading = 0.0,
    required this.lastUpdated,
    this.estimatedArrivalMinutes = 12,
    this.distanceRemainingKm = 2.4,
  });

  Map<String, dynamic> toMap() {
    return {
      'trackingId': trackingId,
      'donationId': donationId,
      'deliveryId': deliveryId,
      'volunteerId': volunteerId,
      'volunteerName': volunteerName,
      'currentLat': currentLat,
      'currentLng': currentLng,
      'speedKmh': speedKmh,
      'heading': heading,
      'lastUpdated': lastUpdated.toIso8601String(),
      'estimatedArrivalMinutes': estimatedArrivalMinutes,
      'distanceRemainingKm': distanceRemainingKm,
    };
  }

  factory TrackingModel.fromMap(Map<String, dynamic> map, String id) {
    return TrackingModel(
      trackingId: map['trackingId'] as String? ?? id,
      donationId: map['donationId'] as String? ?? '',
      deliveryId: map['deliveryId'] as String? ?? '',
      volunteerId: map['volunteerId'] as String? ?? '',
      volunteerName: map['volunteerName'] as String? ?? 'Volunteer Driver',
      currentLat: (map['currentLat'] as num? ?? 12.9716).toDouble(),
      currentLng: (map['currentLng'] as num? ?? 77.5946).toDouble(),
      speedKmh: (map['speedKmh'] as num? ?? 25.0).toDouble(),
      heading: (map['heading'] as num? ?? 0.0).toDouble(),
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.tryParse(map['lastUpdated'] as String) ?? DateTime.now()
          : DateTime.now(),
      estimatedArrivalMinutes: (map['estimatedArrivalMinutes'] as num? ?? 12).toInt(),
      distanceRemainingKm: (map['distanceRemainingKm'] as num? ?? 2.4).toDouble(),
    );
  }

  TrackingModel copyWith({
    String? trackingId,
    String? donationId,
    String? deliveryId,
    String? volunteerId,
    String? volunteerName,
    double? currentLat,
    double? currentLng,
    double? speedKmh,
    double? heading,
    DateTime? lastUpdated,
    int? estimatedArrivalMinutes,
    double? distanceRemainingKm,
  }) {
    return TrackingModel(
      trackingId: trackingId ?? this.trackingId,
      donationId: donationId ?? this.donationId,
      deliveryId: deliveryId ?? this.deliveryId,
      volunteerId: volunteerId ?? this.volunteerId,
      volunteerName: volunteerName ?? this.volunteerName,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      speedKmh: speedKmh ?? this.speedKmh,
      heading: heading ?? this.heading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      estimatedArrivalMinutes: estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
      distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
    );
  }

  @override
  List<Object?> get props => [
        trackingId,
        donationId,
        deliveryId,
        volunteerId,
        volunteerName,
        currentLat,
        currentLng,
        speedKmh,
        heading,
        lastUpdated,
        estimatedArrivalMinutes,
        distanceRemainingKm,
      ];
}
