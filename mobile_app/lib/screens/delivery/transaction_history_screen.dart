import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/wallet_transaction_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class TransactionHistoryScreen extends ConsumerWidget {
  const TransactionHistoryScreen({super.key});

  static String _formatPaymentSource(PaymentSource source) {
    switch (source) {
      case PaymentSource.commercialDonor:
        return 'Commercial Donor Fee';
      case PaymentSource.rescueMealOrder:
        return 'Rescue Meal Order';
      case PaymentSource.sponsoredDelivery:
        return 'CSR Sponsored Delivery';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletNotifierProvider);
    final txns = walletState.transactions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Transaction History',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: txns.isEmpty
          ? const Center(child: Text('No transaction history found.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: txns.length,
              itemBuilder: (context, index) {
                final txn = txns[index];
                return GlassCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_card_rounded, color: AppColors.primary, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatPaymentSource(txn.paymentSource),
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                  ),
                                  Text(
                                    'Delivery: ${txn.deliveryId} • Donation: ${txn.donationId}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text(
                            '+₹${txn.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _ChipBadge(label: 'Base Pay: ₹${txn.basePay.toStringAsFixed(0)}'),
                          _ChipBadge(label: 'Distance: ₹${txn.distancePay.toStringAsFixed(0)}'),
                          _ChipBadge(label: 'Peak Bonus: ₹${txn.peakHourBonus.toStringAsFixed(0)}'),
                          _ChipBadge(label: 'Carbon Bonus: ₹${txn.carbonBonus.toStringAsFixed(0)}'),
                          if (txn.tip > 0) _ChipBadge(label: 'Tip: ₹${txn.tip.toStringAsFixed(0)}', isAccent: true),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _ChipBadge extends StatelessWidget {
  final String label;
  final bool isAccent;

  const _ChipBadge({required this.label, this.isAccent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAccent ? Colors.amber.withValues(alpha: 0.2) : AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isAccent ? Colors.amber.shade900 : AppColors.textSecondary,
        ),
      ),
    );
  }
}
