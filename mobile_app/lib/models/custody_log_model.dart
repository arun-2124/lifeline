import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CustodyLogModel extends Equatable {
  final String logId;
  final String donationId;
  final String deliveryId;
  final String eventType; // DONATION_CREATED, QR_GENERATED, NGO_RESERVED, VOLUNTEER_ASSIGNED, PICKUP_VERIFIED, IN_TRANSIT, NGO_VERIFIED, BENEFICIARY_CONFIRMED, COMPLETED
  final String userId;
  final String userName;
  final String userRole;
  final double latitude;
  final double longitude;
  final String deviceId;
  final DateTime timestamp;
  final String securityHash;
  final String? notes;

  const CustodyLogModel({
    required this.logId,
    required this.donationId,
    required this.deliveryId,
    required this.eventType,
    required this.userId,
    required this.userName,
    required this.userRole,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    this.deviceId = 'DEVICE_ANDROID_V2307',
    required this.timestamp,
    required this.securityHash,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'donationId': donationId,
      'deliveryId': deliveryId,
      'eventType': eventType,
      'userId': userId,
      'userName': userName,
      'userRole': userRole,
      'latitude': latitude,
      'longitude': longitude,
      'deviceId': deviceId,
      'timestamp': Timestamp.fromDate(timestamp),
      'securityHash': securityHash,
      'notes': notes,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory CustodyLogModel.fromMap(Map<String, dynamic> map, String id) {
    return CustodyLogModel(
      logId: map['logId'] as String? ?? id,
      donationId: map['donationId'] as String? ?? '',
      deliveryId: map['deliveryId'] as String? ?? '',
      eventType: map['eventType'] as String? ?? 'DONATION_CREATED',
      userId: map['userId'] as String? ?? '',
      userName: map['userName'] as String? ?? 'System User',
      userRole: map['userRole'] as String? ?? 'Donor',
      latitude: (map['latitude'] as num? ?? 12.9716).toDouble(),
      longitude: (map['longitude'] as num? ?? 77.5946).toDouble(),
      deviceId: map['deviceId'] as String? ?? 'DEVICE_ANDROID_V2307',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      securityHash: map['securityHash'] as String? ?? '',
      notes: map['notes'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        logId,
        donationId,
        deliveryId,
        eventType,
        userId,
        userName,
        userRole,
        latitude,
        longitude,
        deviceId,
        timestamp,
        securityHash,
        notes,
      ];
}
