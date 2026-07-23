import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/filter_bottom_sheet_widget.dart';
import 'package:mobile_app/widgets/ngo_donation_card_widget.dart';

class BrowseDonationsScreen extends ConsumerStatefulWidget {
  const BrowseDonationsScreen({super.key});

  @override
  ConsumerState<BrowseDonationsScreen> createState() => _BrowseDonationsScreenState();
}

class _BrowseDonationsScreenState extends ConsumerState<BrowseDonationsScreen> {
  final _searchController = TextEditingController();

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
    final ngoState = ref.watch(ngoNotifierProvider);
    final donations = ngoState.filteredDonations;
    final isLoading = ngoState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Browse Food Donations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Filter Options',
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
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search food name, category, or area...',
                  prefixIcon: const Icon(Icons.search),
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
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : donations.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              const Text(
                                'No food donations match your search.',
                                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: donations.length,
                          itemBuilder: (context, index) {
                            final donation = donations[index];
                            return NgoDonationCardWidget(
                              donation: donation,
                              onTap: () {
                                ref.read(ngoNotifierProvider.notifier).selectDonation(donation);
                                Navigator.of(context).pushNamed(AppRouter.ngoDetailsRoute);
                              },
                              onAccept: () => _acceptDonation(donation),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
