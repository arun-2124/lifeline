import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommunityEventModel extends Equatable {
  final String eventId;
  final String eventTitle;
  final String eventCategory; // Food Drive, Community Kitchen, Festival Meal Distribution, Disaster Relief, Weekend Food Rescue
  final String location;
  final DateTime eventDate;
  final int targetMeals;
  final int currentRsvpCount;
  final String organizerName;

  const CommunityEventModel({
    required this.eventId,
    required this.eventTitle,
    this.eventCategory = 'Weekend Food Rescue',
    required this.location,
    required this.eventDate,
    this.targetMeals = 500,
    this.currentRsvpCount = 38,
    required this.organizerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventCategory': eventCategory,
      'location': location,
      'eventDate': Timestamp.fromDate(eventDate),
      'targetMeals': targetMeals,
      'currentRsvpCount': currentRsvpCount,
      'organizerName': organizerName,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory CommunityEventModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityEventModel(
      eventId: id,
      eventTitle: map['eventTitle'] as String? ?? 'Community Relief Drive',
      eventCategory: map['eventCategory'] as String? ?? 'Weekend Food Rescue',
      location: map['location'] as String? ?? 'Indiranagar Community Hall, Bangalore',
      eventDate: map['eventDate'] is Timestamp
          ? (map['eventDate'] as Timestamp).toDate()
          : DateTime.now().add(const Duration(days: 2)),
      targetMeals: (map['targetMeals'] as num?)?.toInt() ?? 500,
      currentRsvpCount: (map['currentRsvpCount'] as num?)?.toInt() ?? 38,
      organizerName: map['organizerName'] as String? ?? 'Lifeline Relief Team',
    );
  }

  @override
  List<Object?> get props => [
        eventId,
        eventTitle,
        eventCategory,
        location,
        eventDate,
        targetMeals,
        currentRsvpCount,
        organizerName,
      ];
}
