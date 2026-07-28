import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/community_donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class CommunityDonationDetailsScreen extends ConsumerWidget {
  final CommunityDonationModel donation;

  const CommunityDonationDetailsScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Donation Details',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: donation.isVeg ? AppColors.success.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          donation.isVeg ? 'PURE VEG' : 'NON-VEG',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: donation.isVeg ? AppColors.success : Colors.red,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '${donation.donorTrustScore} Trust Score',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    donation.foodName,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Donor: ${donation.donorName} (${donation.donorType})',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 24),
                  _DetailRow(icon: Icons.groups_rounded, label: 'Portions Available', value: '${donation.quantityPeopleServed} meals'),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.rice_bowl_rounded, label: 'Ingredients', value: donation.ingredients),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.warning_amber_rounded, label: 'Allergens', value: donation.allergenInfo),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.kitchen_rounded, label: 'Storage Method', value: donation.storageMethod),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.location_on_rounded, label: 'Pickup Location', value: donation.pickupAddress),
                  const SizedBox(height: 10),
                  _DetailRow(icon: Icons.access_time_rounded, label: 'Pickup Window', value: donation.pickupWindow),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified_rounded, color: AppColors.success, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Verified Food Safety Guarantee Accepted by Donor',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () async {
                        final user = ref.read(authNotifierProvider).user;
                        if (user != null) {
                          await ref.read(communitySharingNotifierProvider.notifier).reserveFood(donation.donationId, user.uid);
                          if (context.mounted) {
                            Navigator.of(context).pushNamed(
                              AppRouter.communityChatRoute,
                              arguments: donation,
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.white),
                      label: const Text(
                        'Reserve Food & Chat with Donor',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.primary, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
              Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ],
    );
  }
}
