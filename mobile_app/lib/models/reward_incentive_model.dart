import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class RewardIncentiveModel extends Equatable {
  final String rewardId;
  final String badgeName;
  final String description;
  final int targetDeliveries;
  final double bonusAmount;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const RewardIncentiveModel({
    required this.rewardId,
    required this.badgeName,
    required this.description,
    required this.targetDeliveries,
    required this.bonusAmount,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'rewardId': rewardId,
      'badgeName': badgeName,
      'description': description,
      'targetDeliveries': targetDeliveries,
      'bonusAmount': bonusAmount,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt != null ? Timestamp.fromDate(unlockedAt!) : null,
    };
  }

  factory RewardIncentiveModel.fromMap(Map<String, dynamic> map, String id) {
    return RewardIncentiveModel(
      rewardId: id,
      badgeName: map['badgeName'] as String? ?? 'Delivery Milestone',
      description: map['description'] as String? ?? '',
      targetDeliveries: (map['targetDeliveries'] as num?)?.toInt() ?? 10,
      bonusAmount: (map['bonusAmount'] as num?)?.toDouble() ?? 50.0,
      isUnlocked: map['isUnlocked'] as bool? ?? false,
      unlockedAt: map['unlockedAt'] is Timestamp
          ? (map['unlockedAt'] as Timestamp).toDate()
          : null,
    );
  }

  @override
  List<Object?> get props => [
        rewardId,
        badgeName,
        description,
        targetDeliveries,
        bonusAmount,
        isUnlocked,
        unlockedAt,
      ];
}
