import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/utils/validators.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/custom_text_field.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class WithdrawalRequestScreen extends ConsumerStatefulWidget {
  const WithdrawalRequestScreen({super.key});

  @override
  ConsumerState<WithdrawalRequestScreen> createState() => _WithdrawalRequestScreenState();
}

class _WithdrawalRequestScreenState extends ConsumerState<WithdrawalRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController(text: '500');
  final _bankNameController = TextEditingController(text: 'HDFC Bank');
  final _accountHolderController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _ifscController = TextEditingController(text: 'HDFC0001234');
  final _upiController = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _accountHolderController.text = user.fullName;
      _upiController.text = '${user.fullName.toLowerCase().replaceAll(' ', '')}@okaxis';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _bankNameController.dispose();
    _accountHolderController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _upiController.dispose();
    super.dispose();
  }

  Future<void> _submitWithdrawal() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final wallet = ref.read(walletNotifierProvider).wallet;
    final withdrawAmount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    if (wallet != null && withdrawAmount > wallet.withdrawableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Requested amount exceeds withdrawable balance (₹${wallet.withdrawableBalance.toStringAsFixed(2)})'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final success = await ref.read(walletNotifierProvider.notifier).requestWithdrawal(
          driverUid: user.uid,
          driverName: user.fullName,
          amount: withdrawAmount,
          bankName: _bankNameController.text.trim(),
          accountHolder: _accountHolderController.text.trim(),
          accountNumber: _accountNumberController.text.trim(),
          ifscCode: _ifscController.text.trim().toUpperCase(),
          upiId: _upiController.text.trim(),
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payout request submitted! Admin review in progress.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletNotifierProvider).wallet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Request Payout',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Withdrawable Balance', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        Text(
                          '₹${(wallet?.withdrawableBalance ?? 1250.0).toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    CustomTextField(
                      label: 'Withdrawal Amount (₹)',
                      hint: '500',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Enter amount';
                        final num = double.tryParse(val.trim());
                        if (num == null || num <= 0) return 'Enter valid amount';
                        return null;
                      },
                      prefixIcon: Icons.currency_rupee_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Account Holder Name',
                      hint: 'Rahul Kumar',
                      controller: _accountHolderController,
                      validator: Validators.validateFullName,
                      prefixIcon: Icons.person_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'UPI ID (For Instant Payout)',
                      hint: 'rahul@okaxis',
                      controller: _upiController,
                      prefixIcon: Icons.qr_code_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Bank Name',
                      hint: 'HDFC Bank',
                      controller: _bankNameController,
                      prefixIcon: Icons.account_balance_rounded,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Account Number',
                      hint: '501002394821',
                      controller: _accountNumberController,
                      keyboardType: TextInputType.number,
                      prefixIcon: Icons.pin_outlined,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'IFSC Code',
                      hint: 'HDFC0001234',
                      controller: _ifscController,
                      prefixIcon: Icons.code_rounded,
                    ),
                    const SizedBox(height: 24),
                    CustomButton(
                      text: 'Submit Payout Request',
                      isLoading: _isSubmitting,
                      onPressed: _submitWithdrawal,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
