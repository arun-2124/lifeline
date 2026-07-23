import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/helpers/date_formatter.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/status_badge_widget.dart';

class NgoDonationDetailsScreen extends ConsumerStatefulWidget {
  const NgoDonationDetailsScreen({super.key});

  @override
  ConsumerState<NgoDonationDetailsScreen> createState() => _NgoDonationDetailsScreenState();
}

class _NgoDonationDetailsScreenState extends ConsumerState<NgoDonationDetailsScreen> {
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _acceptDonation(DonationModel donation) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final success = await ref.read(ngoNotifierProvider.notifier).acceptDonation(
          donation: donation,
          ngoId: user.uid,
          ngoName: user.fullName,
          notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted "${donation.foodName}"! Pickup request created.'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ngoState = ref.watch(ngoNotifierProvider);
    final donation = ngoState.selectedDonation;

    if (donation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Donation Details')),
        body: const Center(child: Text('No donation selected.')),
      );
    }

    final hasImages = donation.imageUrls.isNotEmpty;
    final isAvailable = donation.status.toLowerCase() == 'pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Food Rescue Details'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 220,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: hasImages
                  ? Image.network(
                      donation.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.fastfood_outlined,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.fastfood_outlined,
                      size: 64,
                      color: AppColors.primary,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
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
                            fontSize: 22,
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          donation.foodCategory.replaceAll('_', ' ').toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: donation.foodType == 'Veg'
                              ? AppColors.success.withValues(alpha: 0.1)
                              : AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          donation.foodType,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: donation.foodType == 'Veg' ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          const Text(
                            'Donor Profile',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                radius: 18,
                                child: Icon(Icons.person, color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    donation.donorName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Contact: ${donation.contactNumber}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
                        children: [
                          _NgoInfoRow(
                            icon: Icons.restaurant,
                            label: 'Servings Count',
                            value: '~${donation.numberOfMeals} Meals',
                          ),
                          _NgoInfoRow(
                            icon: Icons.scale_outlined,
                            label: 'Total Quantity',
                            value: '${donation.quantity} ${donation.unit}',
                          ),
                          _NgoInfoRow(
                            icon: Icons.timer_outlined,
                            label: 'Expiry Time',
                            value: DateFormatter.formatTime(donation.expiryTime),
                          ),
                          _NgoInfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Pickup Address',
                            value: donation.pickupAddress,
                          ),
                          _NgoInfoRow(
                            icon: Icons.my_location,
                            label: 'GPS Coordinates',
                            value: '${donation.latitude}, ${donation.longitude}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.map_outlined, size: 36, color: AppColors.primary),
                          const SizedBox(height: 6),
                          Text(
                            'Google Maps GPS Preview (${donation.latitude}, ${donation.longitude})',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isAvailable) ...[
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Pickup Instructions / Notes (Optional)',
                        hintText: 'e.g. NGO van arriving at 3:00 PM',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Accept Food Donation',
                      backgroundColor: AppColors.success,
                      isLoading: ngoState.isLoading,
                      onPressed: () => _acceptDonation(donation),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NgoInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _NgoInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.secondary),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
