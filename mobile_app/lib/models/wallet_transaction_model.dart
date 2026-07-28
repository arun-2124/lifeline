import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum PaymentSource {
  commercialDonor,
  rescueMealOrder,
  sponsoredDelivery,
}

enum TransactionStatus {
  completed,
  pending,
  failed,
}

class WalletTransactionModel extends Equatable {
  final String transactionId;
  final String driverUid;
  final String deliveryId;
  final String donationId;
  final double amount;
  final double basePay;
  final double distancePay;
  final double peakHourBonus;
  final double carbonBonus;
  final double ratingBonus;
  final double tip;
  final PaymentSource paymentSource;
  final TransactionStatus status;
  final DateTime createdAt;

  const WalletTransactionModel({
    required this.transactionId,
    required this.driverUid,
    required this.deliveryId,
    required this.donationId,
    required this.amount,
    this.basePay = 40.0,
    this.distancePay = 15.0,
    this.peakHourBonus = 10.0,
    this.carbonBonus = 5.0,
    this.ratingBonus = 5.0,
    this.tip = 0.0,
    this.paymentSource = PaymentSource.commercialDonor,
    this.status = TransactionStatus.completed,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'transactionId': transactionId,
      'driverUid': driverUid,
      'deliveryId': deliveryId,
      'donationId': donationId,
      'amount': amount,
      'basePay': basePay,
      'distancePay': distancePay,
      'peakHourBonus': peakHourBonus,
      'carbonBonus': carbonBonus,
      'ratingBonus': ratingBonus,
      'tip': tip,
      'paymentSource': paymentSource.name,
      'status': status.name,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory WalletTransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return WalletTransactionModel(
      transactionId: id,
      driverUid: map['driverUid'] as String? ?? '',
      deliveryId: map['deliveryId'] as String? ?? '',
      donationId: map['donationId'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      basePay: (map['basePay'] as num?)?.toDouble() ?? 40.0,
      distancePay: (map['distancePay'] as num?)?.toDouble() ?? 15.0,
      peakHourBonus: (map['peakHourBonus'] as num?)?.toDouble() ?? 10.0,
      carbonBonus: (map['carbonBonus'] as num?)?.toDouble() ?? 5.0,
      ratingBonus: (map['ratingBonus'] as num?)?.toDouble() ?? 5.0,
      tip: (map['tip'] as num?)?.toDouble() ?? 0.0,
      paymentSource: _parsePaymentSource(map['paymentSource']),
      status: _parseTransactionStatus(map['status']),
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  static PaymentSource _parsePaymentSource(dynamic val) {
    if (val == 'rescueMealOrder' || val == 'RESCUE_MEAL_ORDER') {
      return PaymentSource.rescueMealOrder;
    }
    if (val == 'sponsoredDelivery' || val == 'SPONSORED_DELIVERY') {
      return PaymentSource.sponsoredDelivery;
    }
    return PaymentSource.commercialDonor;
  }

  static TransactionStatus _parseTransactionStatus(dynamic val) {
    if (val == 'pending' || val == 'PENDING') return TransactionStatus.pending;
    if (val == 'failed' || val == 'FAILED') return TransactionStatus.failed;
    return TransactionStatus.completed;
  }

  @override
  List<Object?> get props => [
        transactionId,
        driverUid,
        deliveryId,
        donationId,
        amount,
        basePay,
        distancePay,
        peakHourBonus,
        carbonBonus,
        ratingBonus,
        tip,
        paymentSource,
        status,
        createdAt,
      ];
}
