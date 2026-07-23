import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/delivery_request_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/delivery_tracker_widget.dart';
import 'package:mobile_app/widgets/qr_code_card_widget.dart';
import 'package:mobile_app/widgets/status_badge_widget.dart';

class VolunteerTaskDetailsScreen extends ConsumerWidget {
  const VolunteerTaskDetailsScreen({super.key});

  void _updateStatus(BuildContext context, WidgetRef ref, String deliveryId, String nextStatus) async {
    final success = await ref.read(volunteerNotifierProvider.notifier).updateDeliveryStatus(
          deliveryId: deliveryId,
          status: nextStatus,
        );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delivery status updated to "$nextStatus".'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _acceptTask(BuildContext context, WidgetRef ref, DeliveryRequestModel delivery) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final success = await ref.read(volunteerNotifierProvider.notifier).acceptDeliveryTask(
          deliveryId: delivery.deliveryId,
          volunteerId: user.uid,
          volunteerName: user.fullName,
        );

    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted task for "${delivery.foodName}"!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final volunteerState = ref.watch(volunteerNotifierProvider);
    final delivery = volunteerState.selectedDelivery;

    if (delivery == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Delivery Task')),
        body: const Center(child: Text('No delivery task selected.')),
      );
    }

    final isUnassigned = delivery.status == 'Waiting for Volunteer';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Task Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DeliveryTrackerWidget(currentStatus: delivery.status),
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
                            delivery.foodName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        StatusBadgeWidget(status: delivery.status),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '~${delivery.numberOfMeals} Meals • ${delivery.quantity} ${delivery.unit} • ~${delivery.estimatedDistanceKm} km',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const Divider(height: 24, thickness: 1, color: Color(0xFFF1F3F5)),
                    const Text(
                      'Donor Information',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    _TaskInfoTile(
                      icon: Icons.person_outline,
                      title: 'Donor Name',
                      value: delivery.donorName,
                    ),
                    _TaskInfoTile(
                      icon: Icons.phone_outlined,
                      title: 'Donor Contact',
                      value: delivery.donorPhone.isNotEmpty ? delivery.donorPhone : 'Not provided',
                    ),
                    _TaskInfoTile(
                      icon: Icons.location_on_outlined,
                      title: 'Pickup Address',
                      value: delivery.pickupAddress,
                    ),
                    const Divider(height: 24, thickness: 1, color: Color(0xFFF1F3F5)),
                    const Text(
                      'Destination / NGO Information',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    _TaskInfoTile(
                      icon: Icons.business_outlined,
                      title: 'NGO Name',
                      value: delivery.ngoName,
                    ),
                    _TaskInfoTile(
                      icon: Icons.pin_drop_outlined,
                      title: 'Dropoff Location',
                      value: delivery.destinationAddress,
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
                      'Live GPS Navigation Preview (${delivery.pickupLat}, ${delivery.pickupLng})',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            QrCodeCardWidget(donationId: delivery.donationId),
            const SizedBox(height: 24),
            if (isUnassigned) ...[
              CustomButton(
                text: 'Accept Pickup Task',
                isLoading: volunteerState.isLoading,
                onPressed: () => _acceptTask(context, ref, delivery),
              ),
            ] else ...[
              _buildWorkflowActionButtons(context, ref, delivery, volunteerState.isLoading),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkflowActionButtons(
    BuildContext context,
    WidgetRef ref,
    DeliveryRequestModel delivery,
    bool isLoading,
  ) {
    switch (delivery.status) {
      case 'Volunteer Assigned':
        return CustomButton(
          text: 'Start Pickup Route',
          isLoading: isLoading,
          onPressed: () => _updateStatus(context, ref, delivery.deliveryId, 'Pickup Started'),
        );
      case 'Pickup Started':
        return CustomButton(
          text: 'Confirm Food Picked Up',
          backgroundColor: AppColors.warning,
          isLoading: isLoading,
          onPressed: () => _updateStatus(context, ref, delivery.deliveryId, 'Picked Up'),
        );
      case 'Picked Up':
        return CustomButton(
          text: 'On the Way to NGO',
          backgroundColor: Colors.blueAccent,
          isLoading: isLoading,
          onPressed: () => _updateStatus(context, ref, delivery.deliveryId, 'On the Way'),
        );
      case 'On the Way':
        return CustomButton(
          text: 'Mark Delivered to NGO',
          backgroundColor: AppColors.success,
          isLoading: isLoading,
          onPressed: () => _updateStatus(context, ref, delivery.deliveryId, 'Delivered'),
        );
      case 'Delivered':
        return CustomButton(
          text: 'Complete Delivery Task',
          backgroundColor: AppColors.success,
          isLoading: isLoading,
          onPressed: () => _updateStatus(context, ref, delivery.deliveryId, 'Completed'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _TaskInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _TaskInfoTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.secondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
