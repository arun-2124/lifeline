import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/app_drawer_widget.dart';
import 'package:mobile_app/widgets/dashboard_header_widget.dart';
import 'package:mobile_app/widgets/feature_card_widget.dart';
import 'package:mobile_app/widgets/profile_summary_card.dart';

class BeneficiaryHomeScreen extends ConsumerWidget {
  const BeneficiaryHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Beneficiary Dashboard'),
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
                          'Community Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeatureCardWidget(
                          title: 'Nearby Food Centers',
                          description: 'Locate nearby NGO distribution centers and meal schedules.',
                          icon: Icons.place_outlined,
                          iconColor: AppColors.primary,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Food Centers locator coming soon.')),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        FeatureCardWidget(
                          title: 'Request Direct Meal',
                          description: 'Submit an emergency food request for family or self.',
                          icon: Icons.fastfood_outlined,
                          iconColor: Colors.deepOrange,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Direct Meal Request coming soon.')),
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
