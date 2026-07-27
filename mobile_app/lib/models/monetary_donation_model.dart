import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MonetaryDonationModel extends Equatable {
  final String id;
  final String donorId;
  final String donorName;
  final double amount;
  final String currency;
  final String paymentMethod;
  final String transactionId;
  final String? message;
  final DateTime createdAt;

  const MonetaryDonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.amount,
    this.currency = '₹',
    required this.paymentMethod,
    required this.transactionId,
    this.message,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'donorId': donorId,
      'donorName': donorName,
      'amount': amount,
      'currency': currency,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory MonetaryDonationModel.fromMap(Map<String, dynamic> map, String docId) {
    return MonetaryDonationModel(
      id: map['id'] as String? ?? docId,
      donorId: map['donorId'] as String? ?? '',
      donorName: map['donorName'] as String? ?? 'Generous Supporter',
      amount: (map['amount'] as num? ?? 0.0).toDouble(),
      currency: map['currency'] as String? ?? '₹',
      paymentMethod: map['paymentMethod'] as String? ?? 'UPI',
      transactionId: map['transactionId'] as String? ?? '',
      message: map['message'] as String?,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  @override
  List<Object?> get props => [
        id,
        donorId,
        donorName,
        amount,
        currency,
        paymentMethod,
        transactionId,
        message,
        createdAt,
      ];
}
