import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/helpers/date_formatter.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';

class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('User profile not available.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.editProfileRoute);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: user.photoUrl != null && user.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: user.photoUrl == null || user.photoUrl!.isEmpty
                        ? Text(
                            user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : 'U',
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.fullName.isNotEmpty ? user.fullName : 'User Name',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.shield_outlined, size: 16, color: AppColors.primary),
                  label: Text(
                    user.role,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: Icon(
                    user.accountStatus == 'ACTIVE' ? Icons.check_circle_outline : Icons.pending_outlined,
                    size: 16,
                    color: user.accountStatus == 'ACTIVE' ? AppColors.success : AppColors.warning,
                  ),
                  label: Text(
                    user.accountStatus,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: user.accountStatus == 'ACTIVE' ? AppColors.success : AppColors.warning,
                    ),
                  ),
                  backgroundColor: user.accountStatus == 'ACTIVE'
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFFE9ECEF)),
              ),
              color: Colors.white,
              child: Column(
                children: [
                  _ProfileDetailTile(
                    icon: Icons.person_outline,
                    title: 'Full Name',
                    value: user.fullName,
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F3F5)),
                  _ProfileDetailTile(
                    icon: Icons.email_outlined,
                    title: 'Email Address',
                    value: user.email,
                    subtitle: user.isEmailVerified ? 'Verified' : 'Unverified',
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F3F5)),
                  _ProfileDetailTile(
                    icon: Icons.phone_outlined,
                    title: 'Phone Number',
                    value: user.phoneNumber.isNotEmpty ? user.phoneNumber : 'Not provided',
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F3F5)),
                  _ProfileDetailTile(
                    icon: Icons.verified_user_outlined,
                    title: 'Verification Status',
                    value: user.verificationStatus.toUpperCase(),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F3F5)),
                  _ProfileDetailTile(
                    icon: Icons.calendar_today_outlined,
                    title: 'Member Since',
                    value: DateFormatter.formatShortDate(user.createdAt),
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

class _ProfileDetailTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? subtitle;

  const _ProfileDetailTile({
    required this.icon,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.secondary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      subtitle: Text(
        value.isNotEmpty ? value : 'N/A',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
      ),
      trailing: subtitle != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                subtitle!,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.success),
              ),
            )
          : null,
    );
  }
}
