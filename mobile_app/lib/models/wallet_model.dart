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
  final int totalDeliveries;
  final double carbonSavedKg;
  final int mealsDelivered;
  final double rating;
  final DateTime updatedAt;

  const WalletModel({
    required this.uid,
    this.currentBalance = 0.0,
    this.totalEarnings = 0.0,
    this.todayEarnings = 0.0,
    this.weeklyEarnings = 0.0,
    this.monthlyEarnings = 0.0,
    this.lifetimeEarnings = 0.0,
    this.pendingPayments = 0.0,
    this.withdrawableBalance = 0.0,
    this.totalDeliveries = 0,
    this.carbonSavedKg = 0.0,
    this.mealsDelivered = 0,
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
      currentBalance: (map['currentBalance'] as num?)?.toDouble() ?? 0.0,
      totalEarnings: (map['totalEarnings'] as num?)?.toDouble() ?? 0.0,
      todayEarnings: (map['todayEarnings'] as num?)?.toDouble() ?? 0.0,
      weeklyEarnings: (map['weeklyEarnings'] as num?)?.toDouble() ?? 0.0,
      monthlyEarnings: (map['monthlyEarnings'] as num?)?.toDouble() ?? 0.0,
      lifetimeEarnings: (map['lifetimeEarnings'] as num?)?.toDouble() ?? 0.0,
      pendingPayments: (map['pendingPayments'] as num?)?.toDouble() ?? 0.0,
      withdrawableBalance: (map['withdrawableBalance'] as num?)?.toDouble() ?? 0.0,
      totalDeliveries: (map['totalDeliveries'] as num?)?.toInt() ?? 0,
      carbonSavedKg: (map['carbonSavedKg'] as num?)?.toDouble() ?? 0.0,
      mealsDelivered: (map['mealsDelivered'] as num?)?.toInt() ?? 0,
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
        totalDeliveries,
        carbonSavedKg,
        mealsDelivered,
        rating,
        updatedAt,
      ];
}
