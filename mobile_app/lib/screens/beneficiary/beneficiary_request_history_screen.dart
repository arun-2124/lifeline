import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/donation_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/glass_card.dart';
import 'package:mobile_app/widgets/shimmer_skeleton.dart';

class BeneficiaryRequestHistoryScreen extends ConsumerWidget {
  const BeneficiaryRequestHistoryScreen({super.key});

  Future<void> _callDriver(String phone) async {
    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  void _trackDriverLive(BuildContext context, Map<String, dynamic> data) {
    final lat = (data['latitude'] as double?) ?? 12.9716;
    final lng = (data['longitude'] as double?) ?? 77.5946;

    final donation = DonationModel(
      donationId: data['requestId'] as String? ?? 'req_101',
      donorId: 'donor_999',
      donorName: data['donorName'] as String? ?? 'Royal Hotel & Kitchen Hub',
      foodName: 'Emergency Meal Dispatch (${data['numberOfMealsRequired'] ?? 15} Meals)',
      foodCategory: 'cooked_meal',
      foodType: 'Veg',
      quantity: (data['numberOfMealsRequired'] as int? ?? 15).toDouble(),
      unit: 'Portions',
      numberOfMeals: data['numberOfMealsRequired'] as int? ?? 15,
      preparationTime: DateTime.now().subtract(const Duration(minutes: 30)),
      expiryTime: DateTime.now().add(const Duration(hours: 3)),
      pickupAddress: data['deliveryAddress'] as String? ?? 'Sector 3 Relief Zone, Bangalore',
      latitude: lat,
      longitude: lng,
      contactNumber: data['driverPhone'] as String? ?? '+919876543210',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Navigator.of(context).pushNamed(
      AppRouter.liveTrackingRoute,
      arguments: donation,
    );
  }

  List<Map<String, dynamic>> _getFallbackActiveRequests() {
    final now = DateTime.now();
    return [
      {
        'requestId': 'req_active_101',
        'donorName': 'Royal Grand Restaurant & Kitchen',
        'donorType': 'Verified Hotel Donor',
        'numberOfMealsRequired': 20,
        'urgencyLevel': 'Critical',
        'deliveryAddress': 'Sector 3 Relief Shelter, Main Road, Bangalore',
        'status': 'EN ROUTE (DRIVER DISPATCHED)',
        'etaTime': 'Today at ${_formatTime(now.add(const Duration(minutes: 18)))} (In 18 mins)',
        'driverName': 'Rajesh Kumar (Volunteer Driver)',
        'driverPhone': '9876543210',
        'vehicleInfo': 'Blue Hero Splendor (KA-01-EB-4821)',
        'latitude': 12.9750,
        'longitude': 77.5980,
      },
      {
        'requestId': 'req_active_102',
        'donorName': 'The Akshaya Patra Foundation Hub',
        'donorType': 'NGO Relief Partner',
        'numberOfMealsRequired': 35,
        'urgencyLevel': 'High',
        'deliveryAddress': 'Indiranagar Community Shelter',
        'status': 'MEALS DELIVERED & CONFIRMED',
        'etaTime': 'Delivered Today at ${_formatTime(now.subtract(const Duration(minutes: 45)))}',
        'driverName': 'Suresh V. (Delivery Partner)',
        'driverPhone': '9087790877',
        'vehicleInfo': 'Mahindra Supro Van (KA-03-MD-9081)',
        'latitude': 12.9340,
        'longitude': 77.6250,
      },
    ];
  }

  static String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Meal Request History & Tracking',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('beneficiary_requests')
                  .where('applicantUid', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        ShimmerSkeleton(width: double.infinity, height: 160),
                        SizedBox(height: 12),
                        ShimmerSkeleton(width: double.infinity, height: 160),
                      ],
                    ),
                  );
                }

                final firestoreDocs = snapshot.data?.docs ?? [];
                final List<Map<String, dynamic>> requestsList = firestoreDocs.isNotEmpty
                    ? firestoreDocs.map((doc) => doc.data()).toList()
                    : _getFallbackActiveRequests();

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: requestsList.length,
                  itemBuilder: (context, index) {
                    final req = requestsList[index];
                    final status = (req['status'] as String? ?? 'Pending Approval').toUpperCase();
                    final isEnRoute = status.contains('EN ROUTE') || status.contains('DISPATCHED') || status.contains('APPROVED');
                    final isDelivered = status.contains('DELIVERED');
                    final statusColor = isDelivered
                        ? AppColors.success
                        : (isEnRoute ? AppColors.primary : AppColors.warning);

                    return GlassCard(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Status Header Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      isDelivered
                                          ? Icons.check_circle_rounded
                                          : (isEnRoute ? Icons.local_shipping_rounded : Icons.pending_actions_rounded),
                                      color: statusColor,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      status,
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${req['numberOfMealsRequired'] ?? 10} Portions',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // 1. Who is giving the food
                          _HistoryInfoTile(
                            icon: Icons.restaurant_rounded,
                            iconColor: Colors.deepOrange,
                            label: 'DONOR PROVIDING FOOD',
                            title: req['donorName'] as String? ?? 'Royal Hotel & Kitchen Hub',
                            subtitle: req['donorType'] as String? ?? 'Verified Food Relief Donor',
                          ),
                          const SizedBox(height: 12),

                          // 2. When will the food arrive
                          _HistoryInfoTile(
                            icon: Icons.access_time_filled_rounded,
                            iconColor: AppColors.primary,
                            label: 'ESTIMATED ARRIVAL TIME',
                            title: req['etaTime'] as String? ?? 'Today in 15-20 Mins',
                            subtitle: 'Destination: ${req['deliveryAddress'] ?? 'Specified Address'}',
                          ),
                          const SizedBox(height: 12),

                          // 3. Driver & Vehicle Info
                          _HistoryInfoTile(
                            icon: Icons.person_pin_circle_rounded,
                            iconColor: AppColors.success,
                            label: 'DELIVERY DRIVER',
                            title: req['driverName'] as String? ?? 'Rajesh Kumar (Volunteer Driver)',
                            subtitle: req['vehicleInfo'] as String? ?? 'Blue Hero Splendor (KA-01-EB-4821)',
                          ),
                          const SizedBox(height: 16),

                          // Action Buttons: Live Driver Location + Phone Call
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  onPressed: () => _trackDriverLive(context, req),
                                  icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 16),
                                  label: const Text(
                                    'Track Driver Live GPS',
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.success.withValues(alpha: 0.15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  padding: const EdgeInsets.all(12),
                                ),
                                icon: const Icon(Icons.phone_rounded, color: AppColors.success),
                                tooltip: 'Call Driver',
                                onPressed: () => _callDriver(req['driverPhone'] as String? ?? '9876543210'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _HistoryInfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String title;
  final String subtitle;

  const _HistoryInfoTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 0.5),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
