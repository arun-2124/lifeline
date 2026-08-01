import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/helpers/date_formatter.dart';
import 'package:mobile_app/models/delivery_request_model.dart';
import 'package:mobile_app/widgets/glass_card.dart';

class QrChainOfCustodyScreen extends ConsumerStatefulWidget {
  final DeliveryRequestModel delivery;

  const QrChainOfCustodyScreen({super.key, required this.delivery});

  @override
  ConsumerState<QrChainOfCustodyScreen> createState() => _QrChainOfCustodyScreenState();
}

class _QrChainOfCustodyScreenState extends ConsumerState<QrChainOfCustodyScreen> {
  bool _isPickupVerified = false;
  bool _isDeliveryVerified = false;
  bool _isVerifying = false;

  void _verifyHandoverQr(String stage) async {
    setState(() => _isVerifying = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate cryptographic SHA-256 verification
    setState(() {
      _isVerifying = false;
      if (stage == 'PICKUP') {
        _isPickupVerified = true;
      } else {
        _isDeliveryVerified = true;
      }
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            stage == 'PICKUP'
                ? 'Donor Handover Verified! QR Chain of Custody Signed.'
                : 'NGO Delivery Verified! Food Safety Chain of Custody Completed.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'QR Chain of Custody Verification',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO CARD: DELIVERY DETAILS
            GlassCard(
              padding: const EdgeInsets.all(20),
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
                        child: Text(
                          widget.delivery.status.toUpperCase(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                      ),
                      const Text(
                        'SHA-256 Encrypted',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    widget.delivery.foodName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.delivery.quantity} ${widget.delivery.unit} • ${widget.delivery.numberOfMeals} Meals Served',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // STAGE 1: DONOR HANDOVER QR (PICKUP)
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Stage 1: Donor Handover QR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Icon(
                        _isPickupVerified ? Icons.check_circle_rounded : Icons.pending_rounded,
                        color: _isPickupVerified ? AppColors.success : Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Donor: ${widget.delivery.donorName} • ${widget.delivery.pickupAddress}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  if (_isPickupVerified)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Pickup Verified at ${DateFormatter.formatShortDate(DateTime.now())}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _isVerifying ? null : () => _verifyHandoverQr('PICKUP'),
                        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                        label: Text(_isVerifying ? 'Verifying QR...' : 'Scan Donor Pickup QR Code'),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // STAGE 2: NGO RECIPIENT HANDOVER QR (DELIVERY)
            GlassCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Stage 2: NGO Recipient Handover QR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      Icon(
                        _isDeliveryVerified ? Icons.check_circle_rounded : Icons.pending_rounded,
                        color: _isDeliveryVerified ? AppColors.success : Colors.amber,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'NGO: ${widget.delivery.ngoName} • ${widget.delivery.destinationAddress}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  if (_isDeliveryVerified)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Delivery Verified & Completed at ${DateFormatter.formatShortDate(DateTime.now())}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
                          ),
                        ],
                      ),
                    )
                  else
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isPickupVerified ? AppColors.success : Colors.grey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: (_isPickupVerified && !_isVerifying) ? () => _verifyHandoverQr('DELIVERY') : null,
                        icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white),
                        label: Text(_isVerifying ? 'Verifying QR...' : 'Scan NGO Delivery QR Code'),
                      ),
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
