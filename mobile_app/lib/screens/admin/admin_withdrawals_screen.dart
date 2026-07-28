import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/withdrawal_request_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class AdminWithdrawalsScreen extends ConsumerStatefulWidget {
  const AdminWithdrawalsScreen({super.key});

  @override
  ConsumerState<AdminWithdrawalsScreen> createState() => _AdminWithdrawalsScreenState();
}

class _AdminWithdrawalsScreenState extends ConsumerState<AdminWithdrawalsScreen> {
  List<WithdrawalRequestModel> _pendingWithdrawals = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingWithdrawals();
  }

  Future<void> _loadPendingWithdrawals() async {
    setState(() => _isLoading = true);
    final repo = ref.read(walletRepositoryProvider);
    final list = await repo.adminGetAllPendingWithdrawals();
    if (mounted) {
      setState(() {
        _pendingWithdrawals = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayout(WithdrawalRequestModel wd, bool approve) async {
    final repo = ref.read(walletRepositoryProvider);
    final success = await repo.adminApproveWithdrawal(
      withdrawalId: wd.withdrawalId,
      driverUid: wd.driverUid,
      amount: wd.amount,
      approve: approve,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(approve ? 'Payout of ₹${wd.amount} Approved & Processed!' : 'Withdrawal Request Rejected.'),
          backgroundColor: approve ? AppColors.success : AppColors.error,
        ),
      );
      _loadPendingWithdrawals();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Admin Payout Verification Console',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingWithdrawals.isEmpty
              ? const Center(child: Text('No pending payout requests.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingWithdrawals.length,
                  itemBuilder: (context, index) {
                    final wd = _pendingWithdrawals[index];
                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                wd.driverName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Text(
                                '₹${wd.amount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          Text('UPI ID: ${wd.upiId}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                          Text('Bank: ${wd.bankName} • Acc: ${wd.accountNumber} • IFSC: ${wd.ifscCode}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _processPayout(wd, true),
                                  icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                  label: const Text('Approve & Pay', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: AppColors.error),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => _processPayout(wd, false),
                                  icon: const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                                  label: const Text('Reject', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                                ),
                              ),
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
