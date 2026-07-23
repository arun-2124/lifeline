import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';

import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/donation_card_widget.dart';

class MyDonationsScreen extends ConsumerStatefulWidget {
  const MyDonationsScreen({super.key});

  @override
  ConsumerState<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends ConsumerState<MyDonationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(donationNotifierProvider.notifier).loadDonorDonations(user.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final donationState = ref.watch(donationNotifierProvider);
    final donations = donationState.donations;
    final isLoading = donationState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Donations'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Matched'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDonationList(donations),
                _buildDonationList(
                    donations.where((d) => d.status.toLowerCase() == 'pending').toList()),
                _buildDonationList(donations
                    .where((d) =>
                        d.status.toLowerCase() == 'matched' ||
                        d.status.toLowerCase() == 'accepted')
                    .toList()),
                _buildDonationList(donations
                    .where((d) =>
                        d.status.toLowerCase() == 'completed' ||
                        d.status.toLowerCase() == 'delivered')
                    .toList()),
              ],
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

  Widget _buildDonationList(List list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'No donations found.',
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.createDonationRoute);
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Donation'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final donation = list[index];
        return DonationCardWidget(
          donation: donation,
          onTap: () {
            ref.read(donationNotifierProvider.notifier).selectDonation(donation);
            Navigator.of(context).pushNamed(AppRouter.donationDetailsRoute);
          },
        );
      },
    );
  }
}
