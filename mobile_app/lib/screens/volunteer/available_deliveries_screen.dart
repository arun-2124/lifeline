import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/delivery_request_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/delivery_card_widget.dart';

class AvailableDeliveriesScreen extends ConsumerStatefulWidget {
  const AvailableDeliveriesScreen({super.key});

  @override
  ConsumerState<AvailableDeliveriesScreen> createState() => _AvailableDeliveriesScreenState();
}

class _AvailableDeliveriesScreenState extends ConsumerState<AvailableDeliveriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(volunteerNotifierProvider.notifier).loadAvailableDeliveries();
    });
  }

  void _acceptDeliveryTask(DeliveryRequestModel delivery) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final success = await ref.read(volunteerNotifierProvider.notifier).acceptDeliveryTask(
          deliveryId: delivery.deliveryId,
          volunteerId: user.uid,
          volunteerName: user.fullName,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted pickup task for "${delivery.foodName}"!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRouter.volunteerTaskDetailsRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final volunteerState = ref.watch(volunteerNotifierProvider);
    final list = volunteerState.availableDeliveries;
    final isLoading = volunteerState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Available Pickup Tasks'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : list.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_bike_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text(
                        'No available pickup tasks at the moment.',
                        style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (context, index) {
                    final delivery = list[index];
                    return DeliveryCardWidget(
                      delivery: delivery,
                      onTap: () {
                        ref.read(volunteerNotifierProvider.notifier).selectDelivery(delivery);
                        Navigator.of(context).pushNamed(AppRouter.volunteerTaskDetailsRoute);
                      },
                      onAccept: () => _acceptDeliveryTask(delivery),
                    );
                  },
                ),
    );
  }
}
