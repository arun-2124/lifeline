import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/widgets/notification_tile_widget.dart';

class NotificationCenterScreen extends ConsumerStatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  ConsumerState<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends ConsumerState<NotificationCenterScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authNotifierProvider).user;
      if (user != null) {
        ref.read(ngoNotifierProvider.notifier).loadNotifications(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ngoState = ref.watch(ngoNotifierProvider);
    final notifications = ngoState.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notification Center'),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'No notifications yet.',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return NotificationTileWidget(
                  notification: notif,
                  onTap: () {
                    if (!notif.isRead) {
                      ref
                          .read(ngoRepositoryProvider)
                          .markNotificationRead(notif.notificationId);
                      final user = ref.read(authNotifierProvider).user;
                      if (user != null) {
                        ref
                            .read(ngoNotifierProvider.notifier)
                            .loadNotifications(user.uid);
                      }
                    }
                  },
                );
              },
            ),
    );
  }
}
