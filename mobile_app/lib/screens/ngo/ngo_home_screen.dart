import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/app_drawer_widget.dart';
import 'package:mobile_app/widgets/dashboard_header_widget.dart';
import 'package:mobile_app/widgets/filter_bottom_sheet_widget.dart';
import 'package:mobile_app/widgets/ngo_donation_card_widget.dart';
import 'package:mobile_app/widgets/profile_summary_card.dart';

class NgoHomeScreen extends ConsumerStatefulWidget {
  const NgoHomeScreen({super.key});

  @override
  ConsumerState<NgoHomeScreen> createState() => _NgoHomeScreenState();
}

class _NgoHomeScreenState extends ConsumerState<NgoHomeScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ngoNotifierProvider.notifier).loadAvailableDonations();
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(ngoNotifierProvider.notifier).loadAcceptedRequests(user.uid);
        ref.read(ngoNotifierProvider.notifier).loadNotifications(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _acceptDonation(DonationModel donation) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final success = await ref.read(ngoNotifierProvider.notifier).acceptDonation(
          donation: donation,
          ngoId: user.uid,
          ngoName: user.fullName,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted "${donation.foodName}"! Pickup request created.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final ngoState = ref.watch(ngoNotifierProvider);
    final available = ngoState.filteredDonations;
    final acceptedRequests = ngoState.acceptedRequests;
    final unreadNotifications = ngoState.notifications.where((n) => !n.isRead).length;

    final totalClaimedMeals = acceptedRequests.fold<int>(
      0,
      (sum, req) => sum + req.numberOfMeals,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('NGO Portal'),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: 'Notification Center',
                onPressed: () {
                  Navigator.of(context).pushNamed(AppRouter.ngoNotificationsRoute);
                },
              ),
              if (unreadNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Request History',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.ngoHistoryRoute);
            },
          ),
        ],
      ),
      drawer: AppDrawerWidget(user: user),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(ngoNotifierProvider.notifier).loadAvailableDonations();
              },
              child: SingleChildScrollView(
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
                                child: _NgoStatCard(
                                  title: 'Available Food',
                                  value: '${ngoState.availableDonations.length}',
                                  icon: Icons.search,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _NgoStatCard(
                                  title: 'Meals Rescued',
                                  value: '$totalClaimedMeals',
                                  icon: Icons.restaurant_menu,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _NgoStatCard(
                                  title: 'My Pickups',
                                  value: '${acceptedRequests.length}',
                                  icon: Icons.local_shipping_outlined,
                                  color: AppColors.warning,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search food, location...',
                                    prefixIcon: const Icon(Icons.search, size: 20),
                                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFFDEE2E6)),
                                    ),
                                  ),
                                  onChanged: (val) {
                                    ref.read(ngoNotifierProvider.notifier).setSearchQuery(val);
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFDEE2E6)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.tune, color: AppColors.primary),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                      ),
                                      builder: (_) => const FilterBottomSheetWidget(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Nearby Food Donations',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(AppRouter.ngoBrowseRoute);
                                },
                                child: const Text('Browse All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (ngoState.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (available.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.no_meals_outlined, size: 54, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'No matching food donations available right now.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...available.map((d) => NgoDonationCardWidget(
                                  donation: d,
                                  onTap: () {
                                    ref.read(ngoNotifierProvider.notifier).selectDonation(d);
                                    Navigator.of(context).pushNamed(AppRouter.ngoDetailsRoute);
                                  },
                                  onAccept: () => _acceptDonation(d),
                                )),
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

class _NgoStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _NgoStatCard({
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
