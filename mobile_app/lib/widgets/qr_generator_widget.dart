import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/qr_code_model.dart';

class QrGeneratorWidget extends StatelessWidget {
  final QrCodeModel qrCode;

  const QrGeneratorWidget({super.key, required this.qrCode});

  @override
  Widget build(BuildContext context) {
    final isVerified = qrCode.status == 'VERIFIED';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9ECEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isVerified ? Icons.verified : Icons.qr_code_scanner,
                color: isVerified ? AppColors.success : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isVerified ? 'VERIFIED HANDOVER' : 'SECURE RECOVERY QR',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                  color: isVerified ? AppColors.success : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: QrImageView(
              data: qrCode.payloadHash,
              version: QrVersions.auto,
              size: 180.0,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: AppColors.primary,
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Payload: ${qrCode.payloadHash.substring(0, 18)}...',
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
            ),
          ),
          if (isVerified && qrCode.scannedByName != null) ...[
            const SizedBox(height: 10),
            Text(
              'Verified by ${qrCode.scannedByName} (${qrCode.scannedRole})',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.success),
            ),
          ],
        ],
      ),
    );
  }
}
