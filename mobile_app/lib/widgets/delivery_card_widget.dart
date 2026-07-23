import 'package:flutter/material.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/delivery_request_model.dart';
import 'package:mobile_app/widgets/status_badge_widget.dart';

class DeliveryCardWidget extends StatelessWidget {
  final DeliveryRequestModel delivery;
  final VoidCallback onTap;
  final VoidCallback? onAccept;

  const DeliveryCardWidget({
    super.key,
    required this.delivery,
    required this.onTap,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      delivery.foodName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  StatusBadgeWidget(status: delivery.status),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.restaurant, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    '~${delivery.numberOfMeals} Meals • ${delivery.quantity} ${delivery.unit}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
                  ),
                  const Spacer(),
                  const Icon(Icons.navigation_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    '~${delivery.estimatedDistanceKm} km',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
                ],
              ),
              const Divider(height: 20, thickness: 1, color: Color(0xFFF1F3F5)),
              Row(
                children: [
                  const Icon(Icons.circle, size: 10, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 50,
                    child: Text('Pickup:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                  Expanded(
                    child: Text(
                      '${delivery.donorName} (${delivery.pickupAddress})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: AppColors.success),
                  const SizedBox(width: 8),
                  const SizedBox(
                    width: 50,
                    child: Text('Dropoff:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ),
                  Expanded(
                    child: Text(
                      '${delivery.ngoName} (${delivery.destinationAddress})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (onAccept != null && delivery.status == 'Waiting for Volunteer') ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: onAccept,
                    child: const Text('Accept Delivery Task', style: TextStyle(fontWeight: FontWeight.bold)),
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
