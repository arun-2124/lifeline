import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/helpers/date_formatter.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';

import 'package:mobile_app/widgets/qr_code_card_widget.dart';
import 'package:mobile_app/widgets/status_badge_widget.dart';
import 'package:mobile_app/widgets/status_tracker_widget.dart';

class DonationDetailsScreen extends ConsumerWidget {
  const DonationDetailsScreen({super.key});

  void _showCancelDialog(BuildContext context, WidgetRef ref, String donationId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Cancel Food Donation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Are you sure you want to cancel this donation?'),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for cancellation',
                  hintText: 'e.g. Food damaged / Withdrawal',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Keep Active'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () async {
                Navigator.of(dialogCtx).pop();
                final success = await ref
                    .read(donationNotifierProvider.notifier)
                    .cancelDonation(donationId, reasonController.text.trim());

                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Donation cancelled.')),
                  );
                }
              },
              child: const Text('Cancel Donation', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donationState = ref.watch(donationNotifierProvider);
    final donation = donationState.selectedDonation;

    if (donation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donation Details')),
        body: const Center(child: Text('No donation selected.')),
      );
    }

    final isCancellable = ['pending', 'published'].contains(donation.status.toLowerCase());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Donation Details'),
        actions: [
          if (isCancellable)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Donation',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.editDonationRoute);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatusTrackerWidget(currentStatus: donation.status),
            const SizedBox(height: 20),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE9ECEF)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            donation.foodName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        StatusBadgeWidget(status: donation.status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _DetailChip(
                          icon: Icons.category_outlined,
                          label: donation.foodCategory.replaceAll('_', ' ').toUpperCase(),
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        _DetailChip(
                          icon: Icons.restaurant,
                          label: '${donation.foodType} • ${donation.numberOfMeals} Meals',
                          color: AppColors.success,
                        ),
                      ],
                    ),
                    const Divider(height: 24, thickness: 1, color: Color(0xFFF1F3F5)),
                    _InfoRow(
                      icon: Icons.scale_outlined,
                      label: 'Quantity',
                      value: '${donation.quantity} ${donation.unit}',
                    ),
                    _InfoRow(
                      icon: Icons.schedule_outlined,
                      label: 'Preparation Time',
                      value: DateFormatter.formatTime(donation.preparationTime),
                    ),
                    _InfoRow(
                      icon: Icons.timer_outlined,
                      label: 'Expiry Time',
                      value: DateFormatter.formatTime(donation.expiryTime),
                    ),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Pickup Address',
                      value: donation.pickupAddress,
                    ),
                    _InfoRow(
                      icon: Icons.my_location_outlined,
                      label: 'GPS Coordinates',
                      value: '${donation.latitude}, ${donation.longitude}',
                    ),
                    _InfoRow(
                      icon: Icons.phone_outlined,
                      label: 'Contact Phone',
                      value: donation.contactNumber,
                    ),
                    if (donation.specialInstructions != null &&
                        donation.specialInstructions!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.note_outlined,
                        label: 'Special Instructions',
                        value: donation.specialInstructions!,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            QrCodeCardWidget(donationId: donation.donationId),
            const SizedBox(height: 24),
            if (isCancellable)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _showCancelDialog(context, ref, donation.donationId),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Donation', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _DetailChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
