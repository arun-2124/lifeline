import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';

class DeliveryTrackerWidget extends StatelessWidget {
  final String currentStatus;

  static const List<String> stages = [
    'Assigned',
    'Pickup Started',
    'Picked Up',
    'On the Way',
    'Delivered',
    'Completed',
  ];

  const DeliveryTrackerWidget({super.key, required this.currentStatus});

  int get currentStep {
    switch (currentStatus.trim().toLowerCase()) {
      case 'volunteer assigned':
        return 0;
      case 'pickup started':
        return 1;
      case 'picked up':
        return 2;
      case 'on the way':
      case 'in_transit':
        return 3;
      case 'delivered':
        return 4;
      case 'completed':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStep = currentStep;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Live Delivery Progress',
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
                        radius: 11,
                        backgroundColor: isCompleted ? AppColors.primary : const Color(0xFFDEE2E6),
                        child: isCompleted
                            ? Icon(
                                isCurrent ? Icons.directions_bike : Icons.check,
                                size: 11,
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
                      fontSize: 9,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCompleted ? AppColors.primary : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
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
