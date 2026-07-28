import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CsrSponsorModel extends Equatable {
  final String sponsorId;
  final String companyName;
  final String logoUrl;
  final int sponsoredDeliveriesCount;
  final double carbonOffsetKg;
  final int mealsSponsored;
  final String csrCertificateUrl;
  final DateTime joinedAt;

  const CsrSponsorModel({
    required this.sponsorId,
    required this.companyName,
    required this.logoUrl,
    required this.sponsoredDeliveriesCount,
    required this.carbonOffsetKg,
    required this.mealsSponsored,
    required this.csrCertificateUrl,
    required this.joinedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'sponsorId': sponsorId,
      'companyName': companyName,
      'logoUrl': logoUrl,
      'sponsoredDeliveriesCount': sponsoredDeliveriesCount,
      'carbonOffsetKg': carbonOffsetKg,
      'mealsSponsored': mealsSponsored,
      'csrCertificateUrl': csrCertificateUrl,
      'joinedAt': FieldValue.serverTimestamp(),
    };
  }

  factory CsrSponsorModel.fromMap(Map<String, dynamic> map, String id) {
    return CsrSponsorModel(
      sponsorId: id,
      companyName: map['companyName'] as String? ?? 'Corporate Sponsor',
      logoUrl: map['logoUrl'] as String? ?? '',
      sponsoredDeliveriesCount: (map['sponsoredDeliveriesCount'] as num?)?.toInt() ?? 0,
      carbonOffsetKg: (map['carbonOffsetKg'] as num?)?.toDouble() ?? 0.0,
      mealsSponsored: (map['mealsSponsored'] as num?)?.toInt() ?? 0,
      csrCertificateUrl: map['csrCertificateUrl'] as String? ?? '',
      joinedAt: map['joinedAt'] is Timestamp
          ? (map['joinedAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        sponsorId,
        companyName,
        logoUrl,
        sponsoredDeliveriesCount,
        carbonOffsetKg,
        mealsSponsored,
        csrCertificateUrl,
        joinedAt,
      ];
}
