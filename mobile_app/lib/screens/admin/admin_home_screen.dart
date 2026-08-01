import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/app_drawer_widget.dart';
import 'package:mobile_app/widgets/dashboard_header_widget.dart';
import 'package:mobile_app/widgets/feature_card_widget.dart';
import 'package:mobile_app/screens/admin/admin_audit_log_screen.dart';
import 'package:mobile_app/widgets/profile_summary_card.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Console',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
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
                          'System Administration',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeatureCardWidget(
                          title: 'User Verification Requests',
                          description: 'Approve NGO registrations, food safety credentials, and volunteer IDs.',
                          icon: Icons.verified_user_rounded,
                          iconColor: AppColors.primary,
                          tag: 'Live Module',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.adminVerificationRoute);
                          },
                        ),
                        const SizedBox(height: 10),
                        FeatureCardWidget(
                          title: 'Payout Verification Console',
                          description: 'Review, approve, or reject Delivery Partner bank & UPI withdrawal requests.',
                          icon: Icons.payments_rounded,
                          iconColor: AppColors.success,
                          tag: 'FinTech Admin',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.adminWithdrawalsRoute);
                          },
                        ),
                        const SizedBox(height: 10),
                        FeatureCardWidget(
                          title: 'Home Cook Level 2–5 Verification',
                          description: 'Review ID proofs & kitchen hygiene photos for Home Cook upgrades.',
                          icon: Icons.workspace_premium_rounded,
                          iconColor: Colors.amber,
                          tag: 'Level Upgrade',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.adminHomeCookVerificationRoute);
                          },
                        ),
                        const SizedBox(height: 10),
                        FeatureCardWidget(
                          title: 'System Analytics & Audit Logs',
                          description: 'Monitor live donations, AI matching performance, and security logs.',
                          icon: Icons.analytics_outlined,
                          iconColor: AppColors.secondary,
                          tag: 'Live Module',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AdminAuditLogScreen()),
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
