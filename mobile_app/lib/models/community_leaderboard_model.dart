import 'package:equatable/equatable.dart';

enum LeaderboardCategory {
  homeCooks,
  families,
  communities,
  ngos,
  volunteers,
  carbonSavers,
}

class CommunityLeaderboardModel extends Equatable {
  final int rank;
  final String uid;
  final String name;
  final String photoUrl;
  final LeaderboardCategory category;
  final int mealsShared;
  final double carbonSavedKg;
  final double trustScore;

  const CommunityLeaderboardModel({
    required this.rank,
    required this.uid,
    required this.name,
    this.photoUrl = '',
    required this.category,
    required this.mealsShared,
    required this.carbonSavedKg,
    required this.trustScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'rank': rank,
      'uid': uid,
      'name': name,
      'photoUrl': photoUrl,
      'category': category.name,
      'mealsShared': mealsShared,
      'carbonSavedKg': carbonSavedKg,
      'trustScore': trustScore,
    };
  }

  factory CommunityLeaderboardModel.fromMap(Map<String, dynamic> map, String id) {
    return CommunityLeaderboardModel(
      rank: (map['rank'] as num?)?.toInt() ?? 1,
      uid: id,
      name: map['name'] as String? ?? 'Community Champion',
      photoUrl: map['photoUrl'] as String? ?? '',
      category: _parseCategory(map['category']),
      mealsShared: (map['mealsShared'] as num?)?.toInt() ?? 0,
      carbonSavedKg: (map['carbonSavedKg'] as num?)?.toDouble() ?? 0.0,
      trustScore: (map['trustScore'] as num?)?.toDouble() ?? 5.0,
    );
  }

  static LeaderboardCategory _parseCategory(dynamic val) {
    if (val == 'families') return LeaderboardCategory.families;
    if (val == 'communities') return LeaderboardCategory.communities;
    if (val == 'ngos') return LeaderboardCategory.ngos;
    if (val == 'volunteers') return LeaderboardCategory.volunteers;
    if (val == 'carbonSavers') return LeaderboardCategory.carbonSavers;
    return LeaderboardCategory.homeCooks;
  }

  @override
  List<Object?> get props => [
        rank,
        uid,
        name,
        photoUrl,
        category,
        mealsShared,
        carbonSavedKg,
        trustScore,
      ];
}
