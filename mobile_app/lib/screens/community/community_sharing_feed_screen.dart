import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class CommunitySharingFeedScreen extends ConsumerStatefulWidget {
  const CommunitySharingFeedScreen({super.key});

  @override
  ConsumerState<CommunitySharingFeedScreen> createState() => _CommunitySharingFeedScreenState();
}

class _CommunitySharingFeedScreenState extends ConsumerState<CommunitySharingFeedScreen> {
  String _searchQuery = '';
  String _selectedFilter = 'All'; // All, Veg, Non-Veg, Community Kitchen

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(communitySharingNotifierProvider.notifier).loadCommunityDonations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(communitySharingNotifierProvider);
    final donations = state.donations.where((d) {
      final matchesSearch = d.foodName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.donorName.toLowerCase().contains(_searchQuery.toLowerCase());
      if (!matchesSearch) return false;
      if (_selectedFilter == 'Veg') return d.isVeg;
      if (_selectedFilter == 'Non-Veg') return !d.isVeg;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Community Food Sharing Feed',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Share Home Food',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.createCommunityDonationRoute);
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'share_home_food_fab',
        backgroundColor: AppColors.primary,
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.createCommunityDonationRoute);
        },
        icon: const Icon(Icons.soup_kitchen_rounded, color: Colors.white),
        label: const Text('Share Home Food', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search home-cooked food or donor name...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    filled: true,
                    fillColor: AppColors.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Veg', 'Non-Veg', 'Community Kitchen'].map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          onSelected: (_) => setState(() => _selectedFilter = filter),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Community Feed List
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : donations.isEmpty
                    ? const Center(child: Text('No community food sharing listings available right now.'))
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: donations.length,
                        itemBuilder: (context, index) {
                          final item = donations[index];
                          return GlassCard(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: item.isVeg ? AppColors.success.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.circle,
                                            color: item.isVeg ? AppColors.success : Colors.red,
                                            size: 10,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            item.isVeg ? 'PURE VEG' : 'NON-VEG',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: item.isVeg ? AppColors.success : Colors.red,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                        const SizedBox(width: 2),
                                        Text(
                                          '${item.donorTrustScore} Trust Score',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item.foodName,
                                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Shared by: ${item.donorName} (${item.donorType})',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.people_alt_outlined, size: 16, color: AppColors.primary),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Serves ${item.quantityPeopleServed} people',
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                        ),
                                      ],
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pushNamed(
                                          AppRouter.communityDonationDetailsRoute,
                                          arguments: item,
                                        );
                                      },
                                      child: const Text('View Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
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
