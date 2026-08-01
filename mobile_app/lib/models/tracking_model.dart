import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TrackingModel extends Equatable {
  final String trackingId;
  final String donationId;
  final String deliveryId;
  final String volunteerId;
  final String volunteerName;
  final double currentLat;
  final double currentLng;
  final double pickupLat;
  final double pickupLng;
  final double destinationLat;
  final double destinationLng;
  final double speedKmh;
  final double heading;
  final DateTime lastUpdated;
  final int estimatedArrivalMinutes;
  final int pickupEtaMinutes;
  final int deliveryEtaMinutes;
  final double distanceRemainingKm;
  final String geofenceStatus; // EN_ROUTE_PICKUP, ARRIVED_PICKUP, PICKUP_COMPLETED, EN_ROUTE_DELIVERY, ARRIVED_DESTINATION, DELIVERED
  final bool isOfflineCached;

  const TrackingModel({
    required this.trackingId,
    required this.donationId,
    required this.deliveryId,
    required this.volunteerId,
    required this.volunteerName,
    required this.currentLat,
    required this.currentLng,
    this.pickupLat = 12.9716,
    this.pickupLng = 77.5946,
    this.destinationLat = 12.9352,
    this.destinationLng = 77.6245,
    this.speedKmh = 28.5,
    this.heading = 45.0,
    required this.lastUpdated,
    this.estimatedArrivalMinutes = 12,
    this.pickupEtaMinutes = 5,
    this.deliveryEtaMinutes = 14,
    this.distanceRemainingKm = 2.4,
    this.geofenceStatus = 'EN_ROUTE_PICKUP',
    this.isOfflineCached = false,
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
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'destinationLat': destinationLat,
      'destinationLng': destinationLng,
      'speedKmh': speedKmh,
      'heading': heading,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'estimatedArrivalMinutes': estimatedArrivalMinutes,
      'pickupEtaMinutes': pickupEtaMinutes,
      'deliveryEtaMinutes': deliveryEtaMinutes,
      'distanceRemainingKm': distanceRemainingKm,
      'geofenceStatus': geofenceStatus,
      'isOfflineCached': isOfflineCached,
      'updatedAt': FieldValue.serverTimestamp(),
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
      pickupLat: (map['pickupLat'] as num? ?? 12.9716).toDouble(),
      pickupLng: (map['pickupLng'] as num? ?? 77.5946).toDouble(),
      destinationLat: (map['destinationLat'] as num? ?? 12.9352).toDouble(),
      destinationLng: (map['destinationLng'] as num? ?? 77.6245).toDouble(),
      speedKmh: (map['speedKmh'] as num? ?? 28.5).toDouble(),
      heading: (map['heading'] as num? ?? 45.0).toDouble(),
      lastUpdated: map['lastUpdated'] is Timestamp
          ? (map['lastUpdated'] as Timestamp).toDate()
          : map['lastUpdated'] != null
              ? DateTime.tryParse(map['lastUpdated'] as String) ?? DateTime.now()
              : DateTime.now(),
      estimatedArrivalMinutes: (map['estimatedArrivalMinutes'] as num? ?? 12).toInt(),
      pickupEtaMinutes: (map['pickupEtaMinutes'] as num? ?? 5).toInt(),
      deliveryEtaMinutes: (map['deliveryEtaMinutes'] as num? ?? 14).toInt(),
      distanceRemainingKm: (map['distanceRemainingKm'] as num? ?? 2.4).toDouble(),
      geofenceStatus: map['geofenceStatus'] as String? ?? 'EN_ROUTE_PICKUP',
      isOfflineCached: map['isOfflineCached'] as bool? ?? false,
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
    double? pickupLat,
    double? pickupLng,
    double? destinationLat,
    double? destinationLng,
    double? speedKmh,
    double? heading,
    DateTime? lastUpdated,
    int? estimatedArrivalMinutes,
    int? pickupEtaMinutes,
    int? deliveryEtaMinutes,
    double? distanceRemainingKm,
    String? geofenceStatus,
    bool? isOfflineCached,
  }) {
    return TrackingModel(
      trackingId: trackingId ?? this.trackingId,
      donationId: donationId ?? this.donationId,
      deliveryId: deliveryId ?? this.deliveryId,
      volunteerId: volunteerId ?? this.volunteerId,
      volunteerName: volunteerName ?? this.volunteerName,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      pickupLat: pickupLat ?? this.pickupLat,
      pickupLng: pickupLng ?? this.pickupLng,
      destinationLat: destinationLat ?? this.destinationLat,
      destinationLng: destinationLng ?? this.destinationLng,
      speedKmh: speedKmh ?? this.speedKmh,
      heading: heading ?? this.heading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      estimatedArrivalMinutes: estimatedArrivalMinutes ?? this.estimatedArrivalMinutes,
      pickupEtaMinutes: pickupEtaMinutes ?? this.pickupEtaMinutes,
      deliveryEtaMinutes: deliveryEtaMinutes ?? this.deliveryEtaMinutes,
      distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
      geofenceStatus: geofenceStatus ?? this.geofenceStatus,
      isOfflineCached: isOfflineCached ?? this.isOfflineCached,
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
        pickupLat,
        pickupLng,
        destinationLat,
        destinationLng,
        speedKmh,
        heading,
        lastUpdated,
        estimatedArrivalMinutes,
        pickupEtaMinutes,
        deliveryEtaMinutes,
        distanceRemainingKm,
        geofenceStatus,
        isOfflineCached,
      ];
}
