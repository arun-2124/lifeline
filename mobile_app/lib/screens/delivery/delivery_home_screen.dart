import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
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
        title: const Text(
          'Delivery Partner Console',
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
                          'Delivery Dispatch',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FeatureCardWidget(
                          title: 'Multi-Stop Route Manager',
                          description: 'Smart multi-stop pickup & dropoff planner powered by Google OR-Tools AI.',
                          icon: Icons.alt_route_rounded,
                          iconColor: AppColors.primary,
                          tag: 'AI Optimized',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.multiStopRouteRoute);
                          },
                        ),
                        const SizedBox(height: 10),
                        FeatureCardWidget(
                          title: 'Turn-by-Turn GPS Navigation',
                          description: 'Real-time 3D driver navigation with live turn directions & Google Maps sync.',
                          icon: Icons.navigation_rounded,
                          iconColor: Colors.blueAccent,
                          tag: 'Live GPS',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.turnByTurnNavigationRoute);
                          },
                        ),
                        const SizedBox(height: 10),
                        FeatureCardWidget(
                          title: 'Earnings & Wallet Dashboard',
                          description: 'View balance, payment breakdown (Base, Distance, Peak, Carbon, Tip), and request payouts.',
                          icon: Icons.account_balance_wallet_rounded,
                          iconColor: AppColors.success,
                          tag: 'FinTech Wallet',
                          onTap: () {
                            Navigator.of(context).pushNamed(AppRouter.deliveryWalletRoute);
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
