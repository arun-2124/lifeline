import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/helpers/date_formatter.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/status_badge_widget.dart';

class NgoHistoryScreen extends ConsumerStatefulWidget {
  const NgoHistoryScreen({super.key});

  @override
  ConsumerState<NgoHistoryScreen> createState() => _NgoHistoryScreenState();
}

class _NgoHistoryScreenState extends ConsumerState<NgoHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(ngoNotifierProvider.notifier).loadAcceptedRequests(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ngoState = ref.watch(ngoNotifierProvider);
    final requests = ngoState.acceptedRequests;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Accepted Food Rescues'),
      ),
      body: requests.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No accepted food requests yet.',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final req = requests[index];
                return Card(
                  elevation: 0,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE9ECEF)),
                  ),
                  color: Colors.white,
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
                                req.foodName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            StatusBadgeWidget(status: req.status),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '~${req.numberOfMeals} Meals • Donor: ${req.donorName}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                req.pickupAddress,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 1, color: Color(0xFFF1F3F5)),
                        Text(
                          'Accepted on ${DateFormatter.formatShortDate(req.requestedAt)} at ${DateFormatter.formatTime(req.requestedAt)}',
                          style: const TextStyle(fontSize: 11, color: AppColors.secondary),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
