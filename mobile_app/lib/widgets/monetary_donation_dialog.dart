import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/monetary_donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';

class MonetaryDonationDialog extends ConsumerStatefulWidget {
  const MonetaryDonationDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MonetaryDonationDialog(),
    );
  }

  @override
  ConsumerState<MonetaryDonationDialog> createState() => _MonetaryDonationDialogState();
}

class _MonetaryDonationDialogState extends ConsumerState<MonetaryDonationDialog> {
  final _amountController = TextEditingController(text: '25');
  final _messageController = TextEditingController();
  
  // Card Fields
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _cardHolderController = TextEditingController();

  // NetBanking Field
  String _selectedBank = 'State Bank of India (SBI)';

  // UPI Field
  final _upiIdController = TextEditingController(text: 'lifeline@upi');

  double _selectedAmount = 25.0;
  String _selectedPaymentMethod = 'UPI / GPay';
  bool _isProcessing = false;

  final List<double> _presetAmounts = [10, 25, 50, 100, 250];
  final List<String> _popularBanks = [
    'State Bank of India (SBI)',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _messageController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardHolderController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _selectPreset(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toInt().toString();
    });
  }

  Future<void> _processPayment() async {
    final user = ref.read(authNotifierProvider).user;
    final amountText = _amountController.text.trim();
    final amount = double.tryParse(amountText) ?? 0.0;

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid donation amount.')),
      );
      return;
    }

    if (_selectedPaymentMethod == 'Card' && _cardNumberController.text.trim().length < 12) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 16-digit Card Number.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    // 1. If UPI / GPay is selected, launch native UPI app (Google Pay / PhonePe / Paytm)
    if (_selectedPaymentMethod == 'UPI / GPay') {
      final upiId = _upiIdController.text.trim().isNotEmpty ? _upiIdController.text.trim() : 'lifeline@upi';
      final upiUri = Uri.parse(
        'upi://pay?pa=$upiId&pn=Lifeline+Food+Rescue&am=${amount.toStringAsFixed(0)}&cu=INR&tn=Food+Rescue+Donation',
      );

      try {
        if (await canLaunchUrl(upiUri)) {
          await launchUrl(upiUri, mode: LaunchMode.externalApplication);
        } else {
          final gpayWebUri = Uri.parse('https://pay.google.com/about/');
          await launchUrl(gpayWebUri, mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        // Fallback
      }
    }

    // 2. Simulate payment processing handshake (1.2s)
    await Future.delayed(const Duration(milliseconds: 1200));

    final donation = MonetaryDonationModel(
      id: '',
      donorId: user?.uid ?? 'anonymous',
      donorName: user?.fullName ?? 'Generous Supporter',
      amount: amount,
      currency: '₹',
      paymentMethod: _selectedPaymentMethod,
      transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
      message: _messageController.text.trim().isNotEmpty ? _messageController.text.trim() : null,
      createdAt: DateTime.now(),
    );

    final success = await ref
        .read(donationNotifierProvider.notifier)
        .submitMonetaryDonation(donation);

    if (mounted) {
      setState(() {
        _isProcessing = false;
      });

      if (success) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Thank you! ₹${amount.toStringAsFixed(0)} donated via $_selectedPaymentMethod! ❤️',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: 24 + bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 30,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGlow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monetary Relief Support',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Fund meals & cold chain logistics',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Donation Amount (₹)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _presetAmounts.map((amt) {
                  final isSelected = _selectedAmount == amt;
                  return GestureDetector(
                    onTap: () => _selectPreset(amt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryGlow,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                )
                              ]
                            : [],
                      ),
                      child: Text(
                        '₹${amt.toInt()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (val) {
                setState(() {
                  _selectedAmount = double.tryParse(val) ?? 0.0;
                });
              },
              decoration: InputDecoration(
                prefixText: '₹ ',
                prefixStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                labelText: 'Custom Amount',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _PaymentMethodChip(
                  label: 'UPI / GPay',
                  icon: Icons.account_balance_wallet_rounded,
                  isSelected: _selectedPaymentMethod == 'UPI / GPay',
                  onTap: () => setState(() => _selectedPaymentMethod = 'UPI / GPay'),
                ),
                const SizedBox(width: 10),
                _PaymentMethodChip(
                  label: 'Card',
                  icon: Icons.credit_card_rounded,
                  isSelected: _selectedPaymentMethod == 'Card',
                  onTap: () => setState(() => _selectedPaymentMethod = 'Card'),
                ),
                const SizedBox(width: 10),
                _PaymentMethodChip(
                  label: 'NetBanking',
                  icon: Icons.account_balance_rounded,
                  isSelected: _selectedPaymentMethod == 'NetBanking',
                  onTap: () => setState(() => _selectedPaymentMethod = 'NetBanking'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Dynamic Inputs depending on selected method
            if (_selectedPaymentMethod == 'UPI / GPay') ...[
              TextField(
                controller: _upiIdController,
                decoration: InputDecoration(
                  labelText: 'VPA / UPI ID',
                  hintText: 'yourname@okaxis / upi',
                  prefixIcon: const Icon(Icons.qr_code_2_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ] else if (_selectedPaymentMethod == 'Card') ...[
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  hintText: '4532 •••• •••• 8921',
                  prefixIcon: const Icon(Icons.credit_card_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      keyboardType: TextInputType.datetime,
                      decoration: InputDecoration(
                        labelText: 'Expiry',
                        hintText: 'MM/YY',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        hintText: '•••',
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else if (_selectedPaymentMethod == 'NetBanking') ...[
              DropdownButtonFormField<String>(
                initialValue: _selectedBank,
                decoration: InputDecoration(
                  labelText: 'Select Bank',
                  prefixIcon: const Icon(Icons.account_balance_rounded, color: AppColors.primary),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _popularBanks.map((bank) {
                  return DropdownMenuItem(
                    value: bank,
                    child: Text(bank, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedBank = val);
                },
              ),
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 6,
                ),
                onPressed: _isProcessing ? null : _processPayment,
                child: _isProcessing
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.lock_rounded, size: 18, color: Colors.white),
                          const SizedBox(width: 10),
                          Text(
                            _selectedPaymentMethod == 'UPI / GPay'
                                ? 'Open GPay & Pay ₹${_selectedAmount.toStringAsFixed(0)}'
                                : 'Pay ₹${_selectedAmount.toStringAsFixed(0)} with $_selectedPaymentMethod',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentMethodChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.secondary : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.secondary : AppColors.surfaceSubtle,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
