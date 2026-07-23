import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/helpers/date_formatter.dart';
import 'package:mobile_app/models/delivery_log_model.dart';

class DeliveryTimelineWidget extends StatelessWidget {
  final List<DeliveryLogModel> logs;

  static const List<String> fullStages = [
    'Donation Created',
    'NGO Accepted',
    'Volunteer Assigned',
    'Pickup Started',
    'Food Picked Up',
    'In Transit',
    'Delivered',
    'Completed',
  ];

  const DeliveryTimelineWidget({super.key, required this.logs});

  @override
  Widget build(BuildContext context) {
    final existingStages = logs.map((l) => l.stage.trim().toLowerCase()).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Complete Delivery Audit Log',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ...fullStages.map((stage) {
          final logMatch = logs.where((l) => l.stage.trim().toLowerCase() == stage.toLowerCase()).firstOrNull;
          final isDone = logMatch != null || existingStages.contains(stage.toLowerCase());

          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isDone ? AppColors.primary : const Color(0xFFDEE2E6),
                      child: isDone
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : const Icon(Icons.circle_outlined, size: 12, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stage,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                          color: isDone ? AppColors.textPrimary : AppColors.textSecondary,
                        ),
                      ),
                      if (logMatch != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          logMatch.description,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${logMatch.performedBy} • ${DateFormatter.formatTime(logMatch.timestamp)}',
                          style: const TextStyle(fontSize: 10, color: AppColors.secondary),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
