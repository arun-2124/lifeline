import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile_app/models/home_cook_profile_model.dart';

enum VerificationRequestStatus {
  pending,
  approved,
  rejected,
}

class VerificationRequestModel extends Equatable {
  final String requestId;
  final String uid;
  final String cookName;
  final VerificationLevel targetLevel;
  final String idProofUrl;
  final String kitchenPhotoUrl;
  final String hygieneSelfDeclaration;
  final VerificationRequestStatus status;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final String? adminNotes;

  const VerificationRequestModel({
    required this.requestId,
    required this.uid,
    required this.cookName,
    required this.targetLevel,
    required this.idProofUrl,
    required this.kitchenPhotoUrl,
    required this.hygieneSelfDeclaration,
    this.status = VerificationRequestStatus.pending,
    required this.requestedAt,
    this.reviewedAt,
    this.adminNotes,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'uid': uid,
      'cookName': cookName,
      'targetLevel': targetLevel.name,
      'idProofUrl': idProofUrl,
      'kitchenPhotoUrl': kitchenPhotoUrl,
      'hygieneSelfDeclaration': hygieneSelfDeclaration,
      'status': status.name,
      'requestedAt': FieldValue.serverTimestamp(),
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'adminNotes': adminNotes,
    };
  }

  factory VerificationRequestModel.fromMap(Map<String, dynamic> map, String id) {
    return VerificationRequestModel(
      requestId: id,
      uid: map['uid'] as String? ?? '',
      cookName: map['cookName'] as String? ?? 'Home Cook',
      targetLevel: _parseLevel(map['targetLevel']),
      idProofUrl: map['idProofUrl'] as String? ?? '',
      kitchenPhotoUrl: map['kitchenPhotoUrl'] as String? ?? '',
      hygieneSelfDeclaration: map['hygieneSelfDeclaration'] as String? ?? '',
      status: _parseStatus(map['status']),
      requestedAt: map['requestedAt'] is Timestamp
          ? (map['requestedAt'] as Timestamp).toDate()
          : DateTime.now(),
      reviewedAt: map['reviewedAt'] is Timestamp
          ? (map['reviewedAt'] as Timestamp).toDate()
          : null,
      adminNotes: map['adminNotes'] as String?,
    );
  }

  static VerificationLevel _parseLevel(dynamic val) {
    if (val == 'level5GoldChef' || val == 'LEVEL_5_GOLD_CHEF') return VerificationLevel.level5GoldChef;
    if (val == 'level4CommunityChef' || val == 'LEVEL_4_COMMUNITY_CHEF') return VerificationLevel.level4CommunityChef;
    if (val == 'level3TrustedHomeCook' || val == 'LEVEL_3_TRUSTED_HOME_COOK') return VerificationLevel.level3TrustedHomeCook;
    return VerificationLevel.level2VerifiedHomeCook;
  }

  static VerificationRequestStatus _parseStatus(dynamic val) {
    if (val == 'approved' || val == 'APPROVED') return VerificationRequestStatus.approved;
    if (val == 'rejected' || val == 'REJECTED') return VerificationRequestStatus.rejected;
    return VerificationRequestStatus.pending;
  }

  @override
  List<Object?> get props => [
        requestId,
        uid,
        cookName,
        targetLevel,
        idProofUrl,
        kitchenPhotoUrl,
        hygieneSelfDeclaration,
        status,
        requestedAt,
        reviewedAt,
        adminNotes,
      ];
}
