import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ImpactProfileModel extends Equatable {
  final String uid;
  final int totalDonations;
  final int mealsShared;
  final int mealsReceived;
  final int deliveriesCompleted;
  final int peopleHelped;
  final double foodRescuedKg;
  final double carbonSavedKg;
  final double wastePreventedKg;
  final int volunteerHours;
  final int rescueMealsCount;
  final int communityRank;

  const ImpactProfileModel({
    required this.uid,
    this.totalDonations = 42,
    this.mealsShared = 350,
    this.mealsReceived = 0,
    this.deliveriesCompleted = 88,
    this.peopleHelped = 290,
    this.foodRescuedKg = 145.0,
    this.carbonSavedKg = 98.5,
    this.wastePreventedKg = 120.0,
    this.volunteerHours = 45,
    this.rescueMealsCount = 310,
    this.communityRank = 4,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'totalDonations': totalDonations,
      'mealsShared': mealsShared,
      'mealsReceived': mealsReceived,
      'deliveriesCompleted': deliveriesCompleted,
      'peopleHelped': peopleHelped,
      'foodRescuedKg': foodRescuedKg,
      'carbonSavedKg': carbonSavedKg,
      'wastePreventedKg': wastePreventedKg,
      'volunteerHours': volunteerHours,
      'rescueMealsCount': rescueMealsCount,
      'communityRank': communityRank,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory ImpactProfileModel.fromMap(Map<String, dynamic> map, String id) {
    return ImpactProfileModel(
      uid: id,
      totalDonations: (map['totalDonations'] as num?)?.toInt() ?? 42,
      mealsShared: (map['mealsShared'] as num?)?.toInt() ?? 350,
      mealsReceived: (map['mealsReceived'] as num?)?.toInt() ?? 0,
      deliveriesCompleted: (map['deliveriesCompleted'] as num?)?.toInt() ?? 88,
      peopleHelped: (map['peopleHelped'] as num?)?.toInt() ?? 290,
      foodRescuedKg: (map['foodRescuedKg'] as num?)?.toDouble() ?? 145.0,
      carbonSavedKg: (map['carbonSavedKg'] as num?)?.toDouble() ?? 98.5,
      wastePreventedKg: (map['wastePreventedKg'] as num?)?.toDouble() ?? 120.0,
      volunteerHours: (map['volunteerHours'] as num?)?.toInt() ?? 45,
      rescueMealsCount: (map['rescueMealsCount'] as num?)?.toInt() ?? 310,
      communityRank: (map['communityRank'] as num?)?.toInt() ?? 4,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        totalDonations,
        mealsShared,
        mealsReceived,
        deliveriesCompleted,
        peopleHelped,
        foodRescuedKg,
        carbonSavedKg,
        wastePreventedKg,
        volunteerHours,
        rescueMealsCount,
        communityRank,
      ];
}
