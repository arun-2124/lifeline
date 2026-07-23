import 'package:equatable/equatable.dart';

class QrCodeModel extends Equatable {
  final String qrId;
  final String donationId;
  final String payloadHash;
  final String status; // ACTIVE, VERIFIED, EXPIRED
  final String? scannedBy;
  final String? scannedByName;
  final String? scannedRole;
  final DateTime? scannedAt;
  final DateTime createdAt;

  const QrCodeModel({
    required this.qrId,
    required this.donationId,
    required this.payloadHash,
    this.status = 'ACTIVE',
    this.scannedBy,
    this.scannedByName,
    this.scannedRole,
    this.scannedAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'qrId': qrId,
      'donationId': donationId,
      'payloadHash': payloadHash,
      'status': status,
      'scannedBy': scannedBy,
      'scannedByName': scannedByName,
      'scannedRole': scannedRole,
      'scannedAt': scannedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory QrCodeModel.fromMap(Map<String, dynamic> map, String id) {
    return QrCodeModel(
      qrId: map['qrId'] as String? ?? id,
      donationId: map['donationId'] as String? ?? '',
      payloadHash: map['payloadHash'] as String? ?? '',
      status: map['status'] as String? ?? 'ACTIVE',
      scannedBy: map['scannedBy'] as String?,
      scannedByName: map['scannedByName'] as String?,
      scannedRole: map['scannedRole'] as String?,
      scannedAt: map['scannedAt'] != null ? DateTime.tryParse(map['scannedAt'] as String) : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  QrCodeModel copyWith({
    String? qrId,
    String? donationId,
    String? payloadHash,
    String? status,
    String? scannedBy,
    String? scannedByName,
    String? scannedRole,
    DateTime? scannedAt,
    DateTime? createdAt,
  }) {
    return QrCodeModel(
      qrId: qrId ?? this.qrId,
      donationId: donationId ?? this.donationId,
      payloadHash: payloadHash ?? this.payloadHash,
      status: status ?? this.status,
      scannedBy: scannedBy ?? this.scannedBy,
      scannedByName: scannedByName ?? this.scannedByName,
      scannedRole: scannedRole ?? this.scannedRole,
      scannedAt: scannedAt ?? this.scannedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        qrId,
        donationId,
        payloadHash,
        status,
        scannedBy,
        scannedByName,
        scannedRole,
        scannedAt,
        createdAt,
      ];
}
