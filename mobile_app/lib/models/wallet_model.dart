import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class WalletModel extends Equatable {
  final String uid;
  final double currentBalance;
  final double totalEarnings;
  final double todayEarnings;
  final double weeklyEarnings;
  final double monthlyEarnings;
  final double lifetimeEarnings;
  final double pendingPayments;
  final double withdrawableBalance;
  final int rewardPoints;
  final double cashbackEarned;
  final double totalDonated;
  final int totalDeliveries;
  final double carbonSavedKg;
  final int mealsDelivered;
  final double rating;
  final DateTime updatedAt;

  const WalletModel({
    required this.uid,
    this.currentBalance = 1250.0,
    this.totalEarnings = 4850.0,
    this.todayEarnings = 450.0,
    this.weeklyEarnings = 1850.0,
    this.monthlyEarnings = 4850.0,
    this.lifetimeEarnings = 14200.0,
    this.pendingPayments = 350.0,
    this.withdrawableBalance = 900.0,
    this.rewardPoints = 1450,
    this.cashbackEarned = 250.0,
    this.totalDonated = 1500.0,
    this.totalDeliveries = 48,
    this.carbonSavedKg = 125.0,
    this.mealsDelivered = 320,
    this.rating = 4.9,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'currentBalance': currentBalance,
      'totalEarnings': totalEarnings,
      'todayEarnings': todayEarnings,
      'weeklyEarnings': weeklyEarnings,
      'monthlyEarnings': monthlyEarnings,
      'lifetimeEarnings': lifetimeEarnings,
      'pendingPayments': pendingPayments,
      'withdrawableBalance': withdrawableBalance,
      'rewardPoints': rewardPoints,
      'cashbackEarned': cashbackEarned,
      'totalDonated': totalDonated,
      'totalDeliveries': totalDeliveries,
      'carbonSavedKg': carbonSavedKg,
      'mealsDelivered': mealsDelivered,
      'rating': rating,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory WalletModel.fromMap(Map<String, dynamic> map, String uid) {
    return WalletModel(
      uid: uid,
      currentBalance: (map['currentBalance'] as num?)?.toDouble() ?? 1250.0,
      totalEarnings: (map['totalEarnings'] as num?)?.toDouble() ?? 4850.0,
      todayEarnings: (map['todayEarnings'] as num?)?.toDouble() ?? 450.0,
      weeklyEarnings: (map['weeklyEarnings'] as num?)?.toDouble() ?? 1850.0,
      monthlyEarnings: (map['monthlyEarnings'] as num?)?.toDouble() ?? 4850.0,
      lifetimeEarnings: (map['lifetimeEarnings'] as num?)?.toDouble() ?? 14200.0,
      pendingPayments: (map['pendingPayments'] as num?)?.toDouble() ?? 350.0,
      withdrawableBalance: (map['withdrawableBalance'] as num?)?.toDouble() ?? 900.0,
      rewardPoints: (map['rewardPoints'] as num?)?.toInt() ?? 1450,
      cashbackEarned: (map['cashbackEarned'] as num?)?.toDouble() ?? 250.0,
      totalDonated: (map['totalDonated'] as num?)?.toDouble() ?? 1500.0,
      totalDeliveries: (map['totalDeliveries'] as num?)?.toInt() ?? 48,
      carbonSavedKg: (map['carbonSavedKg'] as num?)?.toDouble() ?? 125.0,
      mealsDelivered: (map['mealsDelivered'] as num?)?.toInt() ?? 320,
      rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      updatedAt: map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  WalletModel copyWith({
    String? uid,
    double? currentBalance,
    double? totalEarnings,
    double? todayEarnings,
    double? weeklyEarnings,
    double? monthlyEarnings,
    double? lifetimeEarnings,
    double? pendingPayments,
    double? withdrawableBalance,
    int? rewardPoints,
    double? cashbackEarned,
    double? totalDonated,
    int? totalDeliveries,
    double? carbonSavedKg,
    int? mealsDelivered,
    double? rating,
    DateTime? updatedAt,
  }) {
    return WalletModel(
      uid: uid ?? this.uid,
      currentBalance: currentBalance ?? this.currentBalance,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      weeklyEarnings: weeklyEarnings ?? this.weeklyEarnings,
      monthlyEarnings: monthlyEarnings ?? this.monthlyEarnings,
      lifetimeEarnings: lifetimeEarnings ?? this.lifetimeEarnings,
      pendingPayments: pendingPayments ?? this.pendingPayments,
      withdrawableBalance: withdrawableBalance ?? this.withdrawableBalance,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      cashbackEarned: cashbackEarned ?? this.cashbackEarned,
      totalDonated: totalDonated ?? this.totalDonated,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      carbonSavedKg: carbonSavedKg ?? this.carbonSavedKg,
      mealsDelivered: mealsDelivered ?? this.mealsDelivered,
      rating: rating ?? this.rating,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        currentBalance,
        totalEarnings,
        todayEarnings,
        weeklyEarnings,
        monthlyEarnings,
        lifetimeEarnings,
        pendingPayments,
        withdrawableBalance,
        rewardPoints,
        cashbackEarned,
        totalDonated,
        totalDeliveries,
        carbonSavedKg,
        mealsDelivered,
        rating,
        updatedAt,
      ];
}
