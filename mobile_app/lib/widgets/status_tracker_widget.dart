import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';

class StatusTrackerWidget extends StatelessWidget {
  final String currentStatus;

  static const List<String> stages = [
    'Pending',
    'Matched',
    'Picked Up',
    'Delivered',
    'Completed',
  ];

  const StatusTrackerWidget({super.key, required this.currentStatus});

  int get currentStep {
    final status = currentStatus.trim().toLowerCase();
    if (status == 'cancelled' || status == 'expired') return -1;
    switch (status) {
      case 'pending':
      case 'published':
        return 0;
      case 'matched':
      case 'accepted':
        return 1;
      case 'picked up':
      case 'in_transit':
        return 2;
      case 'delivered':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentStatus.trim().toLowerCase() == 'cancelled') {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8D7DA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.error),
            SizedBox(width: 10),
            Text(
              'This donation was cancelled.',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    final activeStep = currentStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Donation Tracking Lifecycle',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(stages.length, (index) {
            final isCompleted = index <= activeStep;
            final isCurrent = index == activeStep;

            return Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      if (index > 0)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: index <= activeStep ? AppColors.primary : const Color(0xFFDEE2E6),
                          ),
                        ),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: isCompleted ? AppColors.primary : const Color(0xFFDEE2E6),
                        child: isCompleted
                            ? Icon(
                                isCurrent ? Icons.circle : Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      if (index < stages.length - 1)
                        Expanded(
                          child: Container(
                            height: 3,
                            color: index < activeStep ? AppColors.primary : const Color(0xFFDEE2E6),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    stages[index],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted ? AppColors.primary : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
