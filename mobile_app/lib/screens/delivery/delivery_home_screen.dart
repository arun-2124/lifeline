import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/app_drawer_widget.dart';
import 'package:mobile_app/widgets/dashboard_header_widget.dart';
import 'package:mobile_app/widgets/feature_card_widget.dart';
import 'package:mobile_app/widgets/profile_summary_card.dart';

class DeliveryHomeScreen extends ConsumerWidget {
  const DeliveryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Delivery Partner Console'),
        elevation: 0,
      ),
      drawer: AppDrawerWidget(user: user),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  DashboardHeaderWidget(user: user),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ProfileSummaryCard(user: user),
                        const SizedBox(height: 20),
                        const Text(
                          'Delivery Dispatch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeatureCardWidget(
                          title: 'Assigned Pickups & Deliveries',
                          description: 'View active route directions and package details.',
                          icon: Icons.local_shipping_outlined,
                          iconColor: AppColors.primary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Delivery Route Manager coming soon.')),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        FeatureCardWidget(
                          title: 'Live GPS Navigation',
                          description: 'Real-time optimized path to donor & recipient locations.',
                          icon: Icons.navigation_outlined,
                          iconColor: Colors.blueAccent,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('GPS Navigation coming soon.')),
                            );
                          },
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
