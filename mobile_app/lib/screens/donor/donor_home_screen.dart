import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';

import 'package:mobile_app/widgets/app_drawer_widget.dart';
import 'package:mobile_app/widgets/dashboard_header_widget.dart';
import 'package:mobile_app/widgets/donation_card_widget.dart';
import 'package:mobile_app/widgets/feature_card_widget.dart';
import 'package:mobile_app/widgets/glass_card.dart';
import 'package:mobile_app/widgets/monetary_donation_dialog.dart';
import 'package:mobile_app/widgets/profile_summary_card.dart';
import 'package:mobile_app/widgets/shimmer_skeleton.dart';

class DonorHomeScreen extends ConsumerStatefulWidget {
  const DonorHomeScreen({super.key});

  @override
  ConsumerState<DonorHomeScreen> createState() => _DonorHomeScreenState();
}

class _DonorHomeScreenState extends ConsumerState<DonorHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDonations();
    });
  }

  Future<void> _fetchDonations() async {
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      await ref.read(donationNotifierProvider.notifier).loadDonorDonations(user.uid);
      await ref.read(donationNotifierProvider.notifier).loadTotalFunds();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final donationState = ref.watch(donationNotifierProvider);
    final donations = donationState.donations;
    final totalFunds = donationState.totalFundsRaised;

    final activeCount = donations
        .where((d) => ['pending', 'published', 'matched', 'accepted', 'picked up']
            .contains(d.status.toLowerCase()))
        .length;

    final totalMeals = donations.fold<int>(
      0,
      (sum, item) => sum + item.numberOfMeals,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Donor Portal',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'My Donations',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.myDonationsRoute);
            },
          ),
        ],
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
              onRefresh: _fetchDonations,
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
                          Row(
                            children: [
                              Expanded(
                                child: _StatCard(
                                  title: 'Total Donations',
                                  value: '${donations.length}',
                                  icon: Icons.volunteer_activism_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Meals Served',
                                  value: '$totalMeals',
                                  icon: Icons.restaurant_menu_rounded,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _StatCard(
                                  title: 'Active',
                                  value: '$activeCount',
                                  icon: Icons.pending_actions_rounded,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // 💸 Total Donated Funds Display & Cash Contribution Banner Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: AppColors.heroGradient,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.secondary.withValues(alpha: 0.3),
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
                                          Icon(Icons.stars_rounded, color: AppColors.primary, size: 14),
                                          SizedBox(width: 4),
                                          Text(
                                            'Community Relief Fund',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.verified_user_rounded, color: Colors.white54, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  '₹${totalFunds.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const Text(
                                  'Total Funds Raised to Feed Underprivileged Communities',
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
                                      MonetaryDonationDialog.show(context);
                                    },
                                    icon: const Icon(Icons.payments_rounded, color: Colors.white, size: 18),
                                    label: const Text(
                                      'Donate Money Now',
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

                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Quick Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(AppRouter.myDonationsRoute);
                                },
                                child: const Text(
                                  'View All',
                                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FeatureCardWidget(
                            title: 'Create Food Donation',
                            description: 'List surplus cooked meals, fresh produce, or bakery items.',
                            icon: Icons.add_circle_outline_rounded,
                            iconColor: AppColors.primary,
                            tag: 'Live Module',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.createDonationRoute);
                            },
                          ),
                          const SizedBox(height: 12),
                          FeatureCardWidget(
                            title: 'Community Food Sharing Feed',
                            description: 'Share home-cooked meals with neighbors & local community members with Food Safety verification.',
                            icon: Icons.soup_kitchen_rounded,
                            iconColor: AppColors.success,
                            tag: 'Community',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.communitySharingFeedRoute);
                            },
                          ),
                          const SizedBox(height: 12),
                          FeatureCardWidget(
                            title: 'Verified Home Cook Portal',
                            description: '5-Level Progression (Level 1 to Gold Chef), Trust Scores, Badges & Impact Dashboard.',
                            icon: Icons.verified_user_rounded,
                            iconColor: Colors.amber,
                            tag: 'Level 1–5 Cook',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.verifiedHomeCookDashboardRoute);
                            },
                          ),
                          const SizedBox(height: 12),
                          FeatureCardWidget(
                            title: 'Lifeline AI Vision Engine',
                            description: 'Snap a photo of food to automatically estimate portions and freshness score.',
                            icon: Icons.linked_camera_rounded,
                            iconColor: Colors.purple,
                            tag: 'AI Vision',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.aiFoodInspectorRoute);
                            },
                          ),
                          const SizedBox(height: 12),
                          FeatureCardWidget(
                            title: 'Corporate ESG Certificate',
                            description: 'Generate downloadable CSR carbon reduction compliance certificates.',
                            icon: Icons.workspace_premium_rounded,
                            iconColor: Colors.amber,
                            tag: 'ESG Certificate',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.esgCertificateRoute);
                            },
                          ),
                          const SizedBox(height: 12),
                          FeatureCardWidget(
                            title: 'Offline Bluetooth Mesh',
                            description: 'Encrypted QR token verification for zero-connectivity disaster zones.',
                            icon: Icons.bluetooth_searching_rounded,
                            iconColor: AppColors.info,
                            tag: 'Offline Mesh',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.offlineMeshRoute);
                            },
                          ),
                          const SizedBox(height: 24),
                          if (donations.isNotEmpty) ...[
                            const Text(
                              'Recent Activity',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...donations.take(3).map((d) => DonationCardWidget(
                                  donation: d,
                                  onTap: () {
                                    ref
                                        .read(donationNotifierProvider.notifier)
                                        .selectDonation(d);
                                    Navigator.of(context)
                                        .pushNamed(AppRouter.donationDetailsRoute);
                                  },
                                )),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 6,
        highlightElevation: 12,
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.createDonationRoute);
        },
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 24),
        label: const Text(
          'Donate Food',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      borderRadius: 16,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
