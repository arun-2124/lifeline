import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum WithdrawalStatus {
  pending,
  approved,
  rejected,
  paid,
}

class WithdrawalRequestModel extends Equatable {
  final String withdrawalId;
  final String driverUid;
  final String driverName;
  final double amount;
  final String bankName;
  final String accountHolder;
  final String accountNumber;
  final String ifscCode;
  final String upiId;
  final WithdrawalStatus status;
  final DateTime requestedAt;
  final DateTime? processedAt;
  final String? adminNote;

  const WithdrawalRequestModel({
    required this.withdrawalId,
    required this.driverUid,
    required this.driverName,
    required this.amount,
    required this.bankName,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifscCode,
    required this.upiId,
    this.status = WithdrawalStatus.pending,
    required this.requestedAt,
    this.processedAt,
    this.adminNote,
  });

  Map<String, dynamic> toMap() {
    return {
      'withdrawalId': withdrawalId,
      'driverUid': driverUid,
      'driverName': driverName,
      'amount': amount,
      'bankName': bankName,
      'accountHolder': accountHolder,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'upiId': upiId,
      'status': status.name,
      'requestedAt': FieldValue.serverTimestamp(),
      'processedAt': processedAt != null ? Timestamp.fromDate(processedAt!) : null,
      'adminNote': adminNote,
    };
  }

  factory WithdrawalRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return WithdrawalRequestModel(
      withdrawalId: id,
      driverUid: map['driverUid'] as String? ?? '',
      driverName: map['driverName'] as String? ?? 'Delivery Partner',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      bankName: map['bankName'] as String? ?? '',
      accountHolder: map['accountHolder'] as String? ?? '',
      accountNumber: map['accountNumber'] as String? ?? '',
      ifscCode: map['ifscCode'] as String? ?? '',
      upiId: map['upiId'] as String? ?? '',
      status: _parseStatus(map['status']),
      requestedAt: map['requestedAt'] is Timestamp
          ? (map['requestedAt'] as Timestamp).toDate()
          : DateTime.now(),
      processedAt: map['processedAt'] is Timestamp
          ? (map['processedAt'] as Timestamp).toDate()
          : null,
      adminNote: map['adminNote'] as String?,
    );
  }

  static WithdrawalStatus _parseStatus(dynamic val) {
    if (val == 'approved' || val == 'APPROVED') return WithdrawalStatus.approved;
    if (val == 'rejected' || val == 'REJECTED') return WithdrawalStatus.rejected;
    if (val == 'paid' || val == 'PAID') return WithdrawalStatus.paid;
    return WithdrawalStatus.pending;
  }

  @override
  List<Object?> get props => [
        withdrawalId,
        driverUid,
        driverName,
        amount,
        bankName,
        accountHolder,
        accountNumber,
        ifscCode,
        upiId,
        status,
        requestedAt,
        processedAt,
        adminNote,
      ];
}
