import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/helpers/date_formatter.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/models/user_model.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class DonationDetailsScreen extends ConsumerWidget {
  final DonationModel donation;

  const DonationDetailsScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hoursLeft = donation.expiryTime.difference(DateTime.now()).inHours;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Donation Details & Lifecycle',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO DONATION CARD WITH STATUS BADGE & EXPIRY
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
                          color: AppColors.primaryGlow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          donation.status.toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: hoursLeft > 2 ? AppColors.success.withValues(alpha: 0.15) : AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Expires in ${hoursLeft > 0 ? hoursLeft : 0}h',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: hoursLeft > 2 ? AppColors.success : AppColors.error),
                        ),
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
                    '${donation.foodCategory} • ${donation.foodType} • ${donation.cuisine} Cuisine',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _InfoTile(label: 'Quantity', value: '${donation.quantity} ${donation.unit}')),
                      Expanded(child: _InfoTile(label: 'Serves', value: '${donation.peopleServed} People')),
                      Expanded(child: _InfoTile(label: 'Storage', value: donation.storageMethod)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // DONOR VERIFICATION & REPUTATION CARD
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                    child: Text(
                      donation.donorName.isNotEmpty ? donation.donorName[0].toUpperCase() : 'D',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donation.donorName,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                        Text(
                          '${UserModel.getVerificationLevelName(donation.donorVerificationLevel)} • ${donation.donorTrustScore} ★',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PICKUP LOCATION & INSTRUCTIONS
            const Text('Pickup Location & Contact', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          donation.pickupAddress,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                  if (donation.landmark != null && donation.landmark!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Landmark: ${donation.landmark}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 6),
                  Text('Contact: ${donation.contactNumber}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // LIFECYCLE TIMELINE
            const Text('Status Lifecycle Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _TimelineNode(title: 'Submitted & Verified', subtitle: DateFormatter.formatShortDate(donation.createdAt), isDone: true),
                  _TimelineNode(title: 'Available for Claim', subtitle: 'Published to local NGOs & Community', isDone: true),
                  _TimelineNode(title: 'Volunteer Assigned', subtitle: donation.assignedVolunteerName ?? 'Pending Volunteer Pickup', isDone: donation.assignedVolunteerId != null),
                  _TimelineNode(title: 'Delivered & Completed', subtitle: 'Recipient distribution verified', isDone: donation.status == 'Completed'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
      ],
    );
  }
}

class _TimelineNode extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDone;

  const _TimelineNode({required this.title, required this.subtitle, required this.isDone});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
          color: isDone ? AppColors.success : AppColors.secondary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDone ? AppColors.textPrimary : AppColors.textSecondary)),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ],
    );
  }
}
