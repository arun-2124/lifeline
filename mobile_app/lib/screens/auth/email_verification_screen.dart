import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/custom_button.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

  Future<void> _openEmailClient() async {
    final url = Uri.parse('mailto:');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        final role = next.user?.role ?? 'Donor';
        Navigator.of(context).pushNamedAndRemoveUntil(
          AppRouter.getHomeRouteForRole(role),
          (route) => false,
        );
      } else if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
      } else if (next.infoMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.infoMessage!),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final email = authState.user?.email ?? 'your email address';
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Email Verification Required'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
            onPressed: isLoading
                ? null
                : () {
                    ref.read(authNotifierProvider.notifier).logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRouter.loginRoute,
                      (route) => false,
                    );
                  },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 72,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verification Email Sent',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'A security verification link has been sent to:\n$email\n\nPlease check your inbox and verify your email to log in.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Note: You must verify your email before gaining access to the Lifeline platform.',
                        style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: 'Refresh Verification Status',
                isLoading: isLoading,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).checkVerificationStatus();
                },
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Open Email App',
                backgroundColor: AppColors.surfaceSubtle,
                textColor: AppColors.textPrimary,
                isLoading: isLoading,
                onPressed: _openEmailClient,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Resend Verification Email',
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
                isLoading: isLoading,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).resendVerificationEmail();
                },
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    AppRouter.loginRoute,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, color: AppColors.error, size: 18),
                label: const Text(
                  'Log Out & Return to Login',
                  style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
