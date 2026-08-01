import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/home_cook_profile_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class VerifiedHomeCookDashboardScreen extends ConsumerStatefulWidget {
  const VerifiedHomeCookDashboardScreen({super.key});

  @override
  ConsumerState<VerifiedHomeCookDashboardScreen> createState() => _VerifiedHomeCookDashboardScreenState();
}

class _VerifiedHomeCookDashboardScreenState extends ConsumerState<VerifiedHomeCookDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(homeCookNotifierProvider.notifier).loadProfile(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeCookNotifierProvider);
    final profile = state.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Verified Home Cook Portal',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            tooltip: 'Community Leaderboard',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.communityLeaderboardRoute);
            },
          ),
        ],
      ),
      body: state.isLoading || profile == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 5-Level Verification Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGlow,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_rounded, color: AppColors.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    HomeCookProfileModel.formatLevelName(profile.verificationLevel),
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.amber.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Rank #${profile.communityRank}',
                                style: const TextStyle(fontSize: 12, color: Colors.amber, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          profile.name,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trust Score: ${profile.trustScore} ★ • Food Safety Rating: ${profile.foodSafetyRating} / 5',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () {
                              Navigator.of(context).pushNamed(AppRouter.homeCookVerificationRoute);
                            },
                            icon: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 16),
                            label: const Text(
                              'Upgrade Verification Level',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Impact & Performance Overview
                  const Text(
                    'Community Impact Overview',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _ImpactTile(label: 'Meals Shared', value: '${profile.mealsShared}', icon: Icons.fastfood_rounded, color: AppColors.primary),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ImpactTile(label: 'People Helped', value: '${profile.peopleHelped}', icon: Icons.groups_rounded, color: AppColors.success),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ImpactTile(label: 'Carbon Saved', value: '${profile.carbonSavedKg.toStringAsFixed(0)} kg', icon: Icons.eco_rounded, color: AppColors.info),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Unlocked Badges Section
                  const Text(
                    'Unlocked Badges & Reputation',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: profile.unlockedBadges.map((badge) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // Quick Action Shortcuts
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: ListTile(
                      leading: const Icon(Icons.analytics_rounded, color: AppColors.primary),
                      title: const Text('Detailed Impact Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('View waste prevented, volunteer hours & monthly growth', style: TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.impactDashboardRoute);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: ListTile(
                      leading: const Icon(Icons.leaderboard_rounded, color: AppColors.success),
                      title: const Text('Community Leaderboard', style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: const Text('Compare ranks among Top Home Cooks & Carbon Savers', style: TextStyle(fontSize: 11)),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRouter.communityLeaderboardRoute);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ImpactTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _ImpactTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
