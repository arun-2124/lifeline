import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/custom_button.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> with SingleTickerProviderStateMixin {
  final _qrIdController = TextEditingController();
  final _otpController = TextEditingController();
  late AnimationController _animController;

  bool _isOtpMode = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    _qrIdController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _verifyScan(String qrId) async {
    if (qrId.trim().isEmpty) return;

    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final success = await ref.read(trackingNotifierProvider.notifier).verifyQrCode(
          qrId: qrId.trim(),
          scannedBy: user.uid,
          scannedByName: user.fullName,
          scannedRole: user.role,
        );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SHA-256 Encrypted QR Code Verified! Chain of Custody signed.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      } else {
        final error = ref.read(trackingNotifierProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'QR Verification failed. Potential fraud attempt logged.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(trackingNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Cryptographic QR Scanner'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isOtpMode ? Icons.qr_code_scanner : Icons.pin_rounded),
            tooltip: _isOtpMode ? 'Switch to QR Scan' : 'Switch to Beneficiary OTP',
            onPressed: () => setState(() => _isOtpMode = !_isOtpMode),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isOtpMode) ...[
                // ANIMATED QR SCANNER FRAME
                AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.primary, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3 * _animController.value),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.qr_code_scanner_rounded, size: 70, color: AppColors.primary),
                                const SizedBox(height: 12),
                                Text(
                                  'Scanning SHA-256 Token...',
                                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 260 * _animController.value - 2,
                            left: 0,
                            right: 0,
                            child: Container(
                              height: 3,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _qrIdController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Enter QR Verification Code',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: Colors.grey.shade900,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade800),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Verify QR Chain of Custody',
                  isLoading: trackingState.isLoading,
                  onPressed: () => _verifyScan(_qrIdController.text),
                ),
              ] else ...[
                // BENEFICIARY OTP CONFIRMATION MODE
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppColors.success, size: 54),
                      const SizedBox(height: 10),
                      const Text(
                        'Beneficiary Receipt Confirmation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter 6-digit OTP provided by beneficiary upon food handover.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8, color: AppColors.textPrimary),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: '123456',
                          filled: true,
                          fillColor: AppColors.surfaceSubtle,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      CustomButton(
                        text: 'Confirm Beneficiary Handover',
                        isLoading: trackingState.isLoading,
                        onPressed: () => _verifyScan('OTP_${_otpController.text}'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
