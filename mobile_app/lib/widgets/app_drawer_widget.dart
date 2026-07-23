import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/models/user_model.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/routes/app_router.dart';

class AppDrawerWidget extends ConsumerWidget {
  final UserModel? user;

  const AppDrawerWidget({super.key, this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = user ?? ref.watch(authNotifierProvider).user;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: currentUser?.photoUrl != null && currentUser!.photoUrl!.isNotEmpty
                  ? NetworkImage(currentUser.photoUrl!)
                  : null,
              child: currentUser?.photoUrl == null || currentUser!.photoUrl!.isEmpty
                  ? Text(
                      currentUser?.fullName.isNotEmpty == true
                          ? currentUser!.fullName[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            accountName: Text(
              currentUser?.fullName ?? 'Lifeline Partner',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            accountEmail: Text(currentUser?.email ?? ''),
          ),
          ListTile(
            leading: const Icon(Icons.person_outlined),
            title: const Text('My Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.profileRoute);
            },
          ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: const Text('Edit Profile'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(AppRouter.editProfileRoute);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shield_outlined, color: AppColors.primary),
            title: const Text('Account Status'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                currentUser?.accountStatus ?? 'ACTIVE',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600),
            ),
            onTap: () {
              Navigator.of(context).pop();
              ref.read(authNotifierProvider.notifier).logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.loginRoute,
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
