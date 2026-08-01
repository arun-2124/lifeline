import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/community_leaderboard_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class CommunityLeaderboardScreen extends ConsumerStatefulWidget {
  const CommunityLeaderboardScreen({super.key});

  @override
  ConsumerState<CommunityLeaderboardScreen> createState() => _CommunityLeaderboardScreenState();
}

class _CommunityLeaderboardScreenState extends ConsumerState<CommunityLeaderboardScreen> {
  LeaderboardCategory _selectedCategory = LeaderboardCategory.homeCooks;

  @override
  Widget build(BuildContext context) {
    final leaderboard = ref.watch(homeCookNotifierProvider).leaderboard;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Community Leaderboard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: Column(
        children: [
          // Category Selector Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ChipItem(label: 'Home Cooks', category: LeaderboardCategory.homeCooks, current: _selectedCategory, onTap: (c) => setState(() => _selectedCategory = c)),
                  _ChipItem(label: 'Families', category: LeaderboardCategory.families, current: _selectedCategory, onTap: (c) => setState(() => _selectedCategory = c)),
                  _ChipItem(label: 'Communities', category: LeaderboardCategory.communities, current: _selectedCategory, onTap: (c) => setState(() => _selectedCategory = c)),
                  _ChipItem(label: 'Carbon Savers', category: LeaderboardCategory.carbonSavers, current: _selectedCategory, onTap: (c) => setState(() => _selectedCategory = c)),
                ],
              ),
            ),
          ),

          // Rankings List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: leaderboard.length,
              itemBuilder: (context, index) {
                final item = leaderboard[index];
                final isTop3 = item.rank <= 3;

                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isTop3 ? Colors.amber : AppColors.surfaceSubtle,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '#${item.rank}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isTop3 ? Colors.black : AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                            Text(
                              '${item.mealsShared} Meals Shared • ${item.carbonSavedKg.toStringAsFixed(0)} kg CO2 Saved',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            '${item.trustScore}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipItem extends StatelessWidget {
  final String label;
  final LeaderboardCategory category;
  final LeaderboardCategory current;
  final ValueChanged<LeaderboardCategory> onTap;

  const _ChipItem({required this.label, required this.category, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = category == current;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primary,
        labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 12),
        onSelected: (_) => onTap(category),
      ),
    );
  }
}
