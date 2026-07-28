import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/app_drawer_widget.dart';
import 'package:mobile_app/widgets/dashboard_header_widget.dart';
import 'package:mobile_app/widgets/feature_card_widget.dart';
import 'package:mobile_app/widgets/glass_card.dart';
import 'package:mobile_app/widgets/profile_summary_card.dart';
import 'package:mobile_app/widgets/shimmer_skeleton.dart';

class BeneficiaryHomeScreen extends ConsumerWidget {
  const BeneficiaryHomeScreen({super.key});

  Future<void> _callReliefHelpline(BuildContext context) async {
    final uri = Uri.parse('tel:1800123456');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Helpline: 1800-123-456 (24/7 Relief Toll-Free)')),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Helpline: 1800-123-456 (24/7 Relief Toll-Free)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final now = DateTime.now();
    final todayStr = '${now.day}/${now.month}/${now.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Beneficiary Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
      ),
      drawer: AppDrawerWidget(user: user),
      body: user == null
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ShimmerSkeleton(width: double.infinity, height: 120),
                  SizedBox(height: 16),
                  ShimmerSkeleton(width: double.infinity, height: 180),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeaderWidget(user: user),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileSummaryCard(user: user),
                          const SizedBox(height: 16),

                          // 🌟 Hero Community Meals Available Banner Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
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
                                      child: const Row(
                                        children: [
                                          Icon(Icons.volunteer_activism_rounded, color: AppColors.primary, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            'Free Community Meals',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      todayStr,
                                      style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  '350+ Free Meals',
                                  style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const Text(
                                  'Available Today Across 3 Nearby Relief Kitchens & Drop Points',
                                  style: TextStyle(fontSize: 12, color: Colors.white70),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 4,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pushNamed(AppRouter.foodCentersLocatorRoute);
                                    },
                                    icon: const Icon(Icons.map_rounded, color: Colors.white, size: 18),
                                    label: const Text(
                                      'Find Food Centers On Map',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Beneficiary KPI Stats Grid
                          const Row(
                            children: [
                              Expanded(
                                child: _BeneficiaryStatCard(
                                  title: 'Nearby Centers',
                                  value: '3 Kitchens',
                                  icon: Icons.place_rounded,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _BeneficiaryStatCard(
                                  title: 'Helpline',
                                  value: '24/7 Relief',
                                  icon: Icons.support_agent_rounded,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            'Emergency & Community Services',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          FeatureCardWidget(
                            title: 'Nearby Food Centers',
                            description: 'Locate nearby NGO distribution centers, community kitchens, and drop-off points.',
                            icon: Icons.place_rounded,
                            iconColor: AppColors.primary,
                            tag: 'Live Map',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.foodCentersLocatorRoute);
                            },
                          ),
                          const SizedBox(height: 10),
                          FeatureCardWidget(
                            title: 'Request Direct Meal',
                            description: 'Submit an emergency food assistance request for family, self, or shelter.',
                            icon: Icons.fastfood_rounded,
                            iconColor: Colors.deepOrange,
                            tag: 'Live Request',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.directMealRequestRoute);
                            },
                          ),
                          const SizedBox(height: 10),
                          FeatureCardWidget(
                            title: 'Community Food Sharing Feed',
                            description: 'Browse nearby home-cooked surplus meals from individuals, families & community kitchens.',
                            icon: Icons.soup_kitchen_rounded,
                            iconColor: AppColors.primary,
                            tag: 'Home Cooked',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.communitySharingFeedRoute);
                            },
                          ),
                          const SizedBox(height: 10),
                          FeatureCardWidget(
                            title: 'Track Deliveries & History',
                            description: 'See who is giving food, estimated arrival time, driver info, and live GPS map tracking.',
                            icon: Icons.navigation_rounded,
                            iconColor: AppColors.success,
                            tag: 'Live Driver GPS',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.beneficiaryRequestHistoryRoute);
                            },
                          ),

                          const SizedBox(height: 24),

                          // Live Emergency Requests Stream from Firestore
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'My Assistance Requests',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(AppRouter.directMealRequestRoute);
                                },
                                icon: const Icon(Icons.add_rounded, size: 16, color: AppColors.primary),
                                label: const Text('New Request', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                            stream: FirebaseFirestore.instance
                                .collection('beneficiary_requests')
                                .where('applicantUid', isEqualTo: user.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const ShimmerSkeleton(width: double.infinity, height: 90);
                              }

                              final docs = snapshot.data?.docs ?? [];
                              if (docs.isEmpty) {
                                return GlassCard(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline_rounded, color: AppColors.textMuted),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'No active meal requests. Tap "Request Direct Meal" above if you need food assistance.',
                                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return Column(
                                children: docs.map((doc) {
                                  final data = doc.data();
                                  final status = data['status'] as String? ?? 'Pending Approval';
                                  final statusColor = status.contains('Approved') || status.contains('Delivered')
                                      ? AppColors.success
                                      : AppColors.warning;

                                  return GlassCard(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(14),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.15),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(Icons.fastfood_rounded, color: statusColor, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${data['numberOfMealsRequired'] ?? 10} Meals Assistance',
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textPrimary,
                                                ),
                                              ),
                                              Text(
                                                '${data['deliveryAddress'] ?? 'Location specified'} • ${data['urgencyLevel'] ?? 'High'} Urgency',
                                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: statusColor.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),

                          const SizedBox(height: 20),

                          // 24/7 Relief Helpline Banner
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceSubtle,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.primaryGlow),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    color: AppColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '24/7 Emergency Food Helpline',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        'Toll-Free Assistance: 1800-123-456',
                                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _callReliefHelpline(context),
                                  child: const Text('Call', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _BeneficiaryStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _BeneficiaryStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
