import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';

import 'package:mobile_app/widgets/app_drawer_widget.dart';
import 'package:mobile_app/widgets/dashboard_header_widget.dart';
import 'package:mobile_app/widgets/donation_card_widget.dart';
import 'package:mobile_app/widgets/feature_card_widget.dart';
import 'package:mobile_app/widgets/profile_summary_card.dart';

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
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(donationNotifierProvider.notifier).loadDonorDonations(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final donationState = ref.watch(donationNotifierProvider);
    final donations = donationState.donations;

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
        title: const Text('Donor Portal'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'My Donations',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.myDonationsRoute);
            },
          ),
        ],
      ),
      drawer: AppDrawerWidget(user: user),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                icon: Icons.restaurant,
                                color: AppColors.success,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _StatCard(
                                title: 'Active',
                                value: '$activeCount',
                                icon: Icons.pending_actions,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Donor Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pushNamed(AppRouter.myDonationsRoute);
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        FeatureCardWidget(
                          title: 'Create Food Donation',
                          description: 'List surplus cooked meals, fresh produce, or bakery items.',
                          icon: Icons.add_circle_outline,
                          iconColor: AppColors.primary,
                          tag: 'Live Module',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.createDonationRoute);
                          },
                        ),
                        const SizedBox(height: 10),
                        FeatureCardWidget(
                          title: 'My Donations List',
                          description: 'Track pickup lifecycle, QR code verification, and status updates.',
                          icon: Icons.history,
                          iconColor: AppColors.success,
                          tag: 'Live Module',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.myDonationsRoute);
                          },
                        ),
                        const SizedBox(height: 20),
                        if (donations.isNotEmpty) ...[
                          const Text(
                            'Recent Donations',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.createDonationRoute);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Donate Food', style: TextStyle(color: Colors.white)),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
