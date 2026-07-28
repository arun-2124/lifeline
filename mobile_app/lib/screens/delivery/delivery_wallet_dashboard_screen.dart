import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/glass_card.dart';
import 'package:mobile_app/widgets/shimmer_skeleton.dart';

class DeliveryWalletDashboardScreen extends ConsumerStatefulWidget {
  const DeliveryWalletDashboardScreen({super.key});

  @override
  ConsumerState<DeliveryWalletDashboardScreen> createState() => _DeliveryWalletDashboardScreenState();
}

class _DeliveryWalletDashboardScreenState extends ConsumerState<DeliveryWalletDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(walletNotifierProvider.notifier).loadWalletData(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletNotifierProvider);
    final wallet = walletState.wallet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Earnings & Wallet',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Transaction History',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.transactionHistoryRoute);
            },
          ),
        ],
      ),
      body: walletState.isLoading || wallet == null
          ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ShimmerSkeleton(width: double.infinity, height: 180),
                  SizedBox(height: 16),
                  ShimmerSkeleton(width: double.infinity, height: 120),
                ],
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                final user = ref.read(authNotifierProvider).user;
                if (user != null) {
                  await ref.read(walletNotifierProvider.notifier).loadWalletData(user.uid);
                }
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glassmorphism Hero Balance Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
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
                                child: const Row(
                                  children: [
                                    Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 14),
                                    SizedBox(width: 4),
                                    Text(
                                      'Withdrawable Balance',
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${wallet.rating} Rating',
                                    style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '₹${wallet.withdrawableBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current Balance: ₹${wallet.currentBalance.toStringAsFixed(2)} • Pending: ₹${wallet.pendingPayments.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(AppRouter.withdrawalRequestRoute);
                                  },
                                  icon: const Icon(Icons.payments_rounded, color: Colors.white, size: 16),
                                  label: const Text(
                                    'Request Payout',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Colors.white70),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(AppRouter.transactionHistoryRoute);
                                  },
                                  icon: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16),
                                  label: const Text(
                                    'History',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Earnings Summary Cards Grid
                    const Text(
                      'Earnings Breakdown',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _EarningCard(title: 'Today', amount: wallet.todayEarnings, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _EarningCard(title: 'Weekly', amount: wallet.weeklyEarnings, color: AppColors.success),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _EarningCard(title: 'Monthly', amount: wallet.monthlyEarnings, color: AppColors.info),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Delivery Impact Metrics Grid
                    const Text(
                      'Impact & Performance Metrics',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Total Deliveries',
                            value: '${wallet.totalDeliveries}',
                            icon: Icons.local_shipping_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Carbon Offset',
                            value: '${wallet.carbonSavedKg.toStringAsFixed(1)} kg',
                            icon: Icons.eco_rounded,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricCard(
                            label: 'Meals Rescued',
                            value: '${wallet.mealsDelivered}',
                            icon: Icons.fastfood_rounded,
                            color: Colors.deepOrange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _MetricCard(
                            label: 'Lifetime Earnings',
                            value: '₹${wallet.lifetimeEarnings.toStringAsFixed(0)}',
                            icon: Icons.monetization_on_rounded,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Navigation Shortcuts (Rewards & CSR)
                    const Text(
                      'Incentives & CSR Sponsorships',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.workspace_premium_rounded, color: AppColors.success),
                        ),
                        title: const Text('Milestone Badges & Rewards', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('Unlock daily & monthly delivery bonus rewards', style: TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRouter.rewardsIncentivesRoute);
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    GlassCard(
                      padding: const EdgeInsets.all(14),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.info.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_user_rounded, color: AppColors.info),
                        ),
                        title: const Text('CSR Corporate Sponsorships', style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text('View corporate delivery sponsors & carbon certificates', style: TextStyle(fontSize: 11)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () {
                          Navigator.of(context).pushNamed(AppRouter.csrSponsorshipRoute);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _EarningCard extends StatelessWidget {
  final String title;
  final double amount;
  final Color color;

  const _EarningCard({required this.title, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Text(
            '₹${amount.toStringAsFixed(0)}',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
