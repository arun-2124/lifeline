import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/delivery_request_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/app_drawer_widget.dart';
import 'package:mobile_app/widgets/dashboard_header_widget.dart';
import 'package:mobile_app/widgets/delivery_card_widget.dart';
import 'package:mobile_app/widgets/feature_card_widget.dart';
import 'package:mobile_app/widgets/profile_summary_card.dart';

class VolunteerHomeScreen extends ConsumerStatefulWidget {
  const VolunteerHomeScreen({super.key});

  @override
  ConsumerState<VolunteerHomeScreen> createState() => _VolunteerHomeScreenState();
}

class _VolunteerHomeScreenState extends ConsumerState<VolunteerHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(volunteerNotifierProvider.notifier).loadAvailableDeliveries();
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(volunteerNotifierProvider.notifier).loadVolunteerDeliveries(user.uid);
      }
    });
  }

  void _acceptDeliveryTask(DeliveryRequestModel delivery) async {
    final user = ref.read(authNotifierProvider).user;
    if (user == null) return;

    final success = await ref.read(volunteerNotifierProvider.notifier).acceptDeliveryTask(
          deliveryId: delivery.deliveryId,
          volunteerId: user.uid,
          volunteerName: user.fullName,
        );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Accepted pickup task for "${delivery.foodName}"!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).user;
    final volunteerState = ref.watch(volunteerNotifierProvider);

    final availableList = volunteerState.availableDeliveries;
    final assignedList = volunteerState.assignedDeliveries;

    final activeTripsCount = assignedList
        .where((d) => ['Volunteer Assigned', 'Pickup Started', 'Picked Up', 'On the Way']
            .contains(d.status))
        .length;

    final completedCount = assignedList
        .where((d) => ['Delivered', 'Completed'].contains(d.status))
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Volunteer Hub'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Delivery History',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.volunteerHistoryRoute);
            },
          ),
        ],
      ),
      drawer: AppDrawerWidget(user: user),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(volunteerNotifierProvider.notifier).loadAvailableDeliveries();
                ref.read(volunteerNotifierProvider.notifier).loadVolunteerDeliveries(user.uid);
              },
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardHeaderWidget(user: user),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfileSummaryCard(user: user),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _VolunteerStatCard(
                                  title: 'Open Tasks',
                                  value: '${availableList.length}',
                                  icon: Icons.assignment_outlined,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _VolunteerStatCard(
                                  title: 'Active Trips',
                                  value: '$activeTripsCount',
                                  icon: Icons.directions_bike,
                                  color: AppColors.warning,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _VolunteerStatCard(
                                  title: 'Completed',
                                  value: '$completedCount',
                                  icon: Icons.check_circle_outline,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Volunteer Actions',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(AppRouter.volunteerAvailableRoute);
                                },
                                child: const Text('Browse All'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          FeatureCardWidget(
                            title: 'Available Pickup Tasks',
                            description: 'View unclaimed food rescue packages waiting for delivery.',
                            icon: Icons.takeout_dining,
                            iconColor: AppColors.primary,
                            tag: 'Live Module',
                            onTap: () {
                              Navigator.of(context).pushNamed(AppRouter.volunteerAvailableRoute);
                            },
                          ),
                          const SizedBox(height: 20),
                          if (assignedList.isNotEmpty) ...[
                            const Text(
                              'My Active Delivery Tasks',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...assignedList.map((delivery) => DeliveryCardWidget(
                                  delivery: delivery,
                                  onTap: () {
                                    ref.read(volunteerNotifierProvider.notifier).selectDelivery(delivery);
                                    Navigator.of(context).pushNamed(AppRouter.volunteerTaskDetailsRoute);
                                  },
                                )),
                          ],
                          const SizedBox(height: 20),
                          const Text(
                            'Open Pickup Opportunities',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (volunteerState.isLoading)
                            const Center(child: CircularProgressIndicator())
                          else if (availableList.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Column(
                                  children: [
                                    Icon(Icons.task_alt, size: 54, color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'No available pickup tasks right now.',
                                      style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ...availableList.take(3).map((delivery) => DeliveryCardWidget(
                                  delivery: delivery,
                                  onTap: () {
                                    ref.read(volunteerNotifierProvider.notifier).selectDelivery(delivery);
                                    Navigator.of(context).pushNamed(AppRouter.volunteerTaskDetailsRoute);
                                  },
                                  onAccept: () => _acceptDeliveryTask(delivery),
                                )),
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

class _VolunteerStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _VolunteerStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE9ECEF)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
