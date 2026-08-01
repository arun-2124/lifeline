import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class CommunityGroupModel extends Equatable {
  final String groupId;
  final String groupName;
  final String description;
  final String groupType; // Neighborhood Food Circle, College Volunteers, Apartment Community, Corporate Volunteers, Local NGOs
  final int memberCount;
  final String leaderName;
  final DateTime createdDate;

  const CommunityGroupModel({
    required this.groupId,
    required this.groupName,
    required this.description,
    this.groupType = 'Neighborhood Food Circle',
    this.memberCount = 124,
    required this.leaderName,
    required this.createdDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'groupName': groupName,
      'description': description,
      'groupType': groupType,
      'memberCount': memberCount,
      'leaderName': leaderName,
      'createdDate': Timestamp.fromDate(createdDate),
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory CommunityGroupModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityGroupModel(
      groupId: id,
      groupName: map['groupName'] as String? ?? 'Community Circle',
      description: map['description'] as String? ?? 'Local surplus food sharing & volunteer group',
      groupType: map['groupType'] as String? ?? 'Neighborhood Food Circle',
      memberCount: (map['memberCount'] as num?)?.toInt() ?? 124,
      leaderName: map['leaderName'] as String? ?? 'Circle Lead',
      createdDate: map['createdDate'] is Timestamp
          ? (map['createdDate'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        groupId,
        groupName,
        description,
        groupType,
        memberCount,
        leaderName,
        createdDate,
      ];
}
