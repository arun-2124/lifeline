import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/delivery_card_widget.dart';

class VolunteerHistoryScreen extends ConsumerStatefulWidget {
  const VolunteerHistoryScreen({super.key});

  @override
  ConsumerState<VolunteerHistoryScreen> createState() => _VolunteerHistoryScreenState();
}

class _VolunteerHistoryScreenState extends ConsumerState<VolunteerHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(volunteerNotifierProvider.notifier).loadVolunteerHistory(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final volunteerState = ref.watch(volunteerNotifierProvider);
    final history = volunteerState.deliveryHistory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery History'),
      ),
      body: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No completed delivery tasks yet.',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final delivery = history[index];
                return DeliveryCardWidget(
                  delivery: delivery,
                  onTap: () {
                    ref.read(volunteerNotifierProvider.notifier).selectDelivery(delivery);
                  },
                );
              },
            ),
    );
  }
}
