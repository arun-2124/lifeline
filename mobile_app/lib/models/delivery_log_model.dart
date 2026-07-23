import 'package:equatable/equatable.dart';

class DeliveryLogModel extends Equatable {
  final String logId;
  final String donationId;
  final String stage; // Donation Created, NGO Accepted, Volunteer Assigned, Pickup Started, Food Picked Up, In Transit, Delivered, Completed
  final String title;
  final String description;
  final DateTime timestamp;
  final String performedBy;

  const DeliveryLogModel({
    required this.logId,
    required this.donationId,
    required this.stage,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.performedBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'logId': logId,
      'donationId': donationId,
      'stage': stage,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'performedBy': performedBy,
    };
  }

  factory DeliveryLogModel.fromMap(Map<String, dynamic> map, String id) {
    return DeliveryLogModel(
      logId: map['logId'] as String? ?? id,
      donationId: map['donationId'] as String? ?? '',
      stage: map['stage'] as String? ?? 'Donation Created',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      performedBy: map['performedBy'] as String? ?? 'System',
    );
  }

  @override
  List<Object?> get props => [logId, donationId, stage, title, description, timestamp, performedBy];
}
