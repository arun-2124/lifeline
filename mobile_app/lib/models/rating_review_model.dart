import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RatingReviewModel extends Equatable {
  final String reviewId;
  final String targetUserId;
  final String reviewerUserId;
  final String reviewerName;
  final double rating;
  final String comment;
  final double foodQualityScore;
  final double communicationScore;
  final double deliveryScore;
  final double reliabilityScore;
  final DateTime createdAt;

  const RatingReviewModel({
    required this.reviewId,
    required this.targetUserId,
    required this.reviewerUserId,
    required this.reviewerName,
    required this.rating,
    required this.comment,
    required this.foodQualityScore,
    required this.communicationScore,
    required this.deliveryScore,
    required this.reliabilityScore,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'reviewId': reviewId,
      'targetUserId': targetUserId,
      'reviewerUserId': reviewerUserId,
      'reviewerName': reviewerName,
      'rating': rating,
      'comment': comment,
      'foodQualityScore': foodQualityScore,
      'communicationScore': communicationScore,
      'deliveryScore': deliveryScore,
      'reliabilityScore': reliabilityScore,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory RatingReviewModel.fromMap(Map<String, dynamic> map, String id) {
    return RatingReviewModel(
      reviewId: id,
      targetUserId: map['targetUserId'] as String? ?? '',
      reviewerUserId: map['reviewerUserId'] as String? ?? '',
      reviewerName: map['reviewerName'] as String? ?? 'Lifeline Member',
      rating: (map['rating'] as num?)?.toDouble() ?? 5.0,
      comment: map['comment'] as String? ?? '',
      foodQualityScore: (map['foodQualityScore'] as num?)?.toDouble() ?? 5.0,
      communicationScore: (map['communicationScore'] as num?)?.toDouble() ?? 5.0,
      deliveryScore: (map['deliveryScore'] as num?)?.toDouble() ?? 5.0,
      reliabilityScore: (map['reliabilityScore'] as num?)?.toDouble() ?? 5.0,
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        reviewId,
        targetUserId,
        reviewerUserId,
        reviewerName,
        rating,
        comment,
        foodQualityScore,
        communicationScore,
        deliveryScore,
        reliabilityScore,
        createdAt,
      ];
}
