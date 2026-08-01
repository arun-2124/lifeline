import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class SecurityAuditLogModel extends Equatable {
  final String alertId;
  final String donationId;
  final String attemptedByUserId;
  final String attemptedByName;
  final String fraudType; // DUPLICATE_SCAN, EXPIRED_TOKEN, UNAUTHORIZED_VOLUNTEER, TAMPERED_SIGNATURE, GEOLOCATION_MISMATCH
  final double riskScore;
  final String status; // FLAGGED, BLOCKED, INVESTIGATING, RESOLVED
  final DateTime timestamp;

  const SecurityAuditLogModel({
    required this.alertId,
    required this.donationId,
    required this.attemptedByUserId,
    required this.attemptedByName,
    required this.fraudType,
    this.riskScore = 8.5,
    this.status = 'BLOCKED',
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'alertId': alertId,
      'donationId': donationId,
      'attemptedByUserId': attemptedByUserId,
      'attemptedByName': attemptedByName,
      'fraudType': fraudType,
      'riskScore': riskScore,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory SecurityAuditLogModel.fromMap(Map<String, dynamic> map, String id) {
    return SecurityAuditLogModel(
      alertId: id,
      donationId: map['donationId'] as String? ?? '',
      attemptedByUserId: map['attemptedByUserId'] as String? ?? '',
      attemptedByName: map['attemptedByName'] as String? ?? 'Unknown User',
      fraudType: map['fraudType'] as String? ?? 'DUPLICATE_SCAN',
      riskScore: (map['riskScore'] as num?)?.toDouble() ?? 8.5,
      status: map['status'] as String? ?? 'BLOCKED',
      timestamp: map['timestamp'] is Timestamp
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        alertId,
        donationId,
        attemptedByUserId,
        attemptedByName,
        fraudType,
        riskScore,
        status,
        timestamp,
      ];
}
