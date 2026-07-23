import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/widgets/custom_button.dart';

class EmailVerificationScreen extends ConsumerWidget {
  const EmailVerificationScreen({super.key});

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
    final email = authState.user?.email ?? 'your email';
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Verify Your Email'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_unread_outlined,
                  size: 72,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verify Your Email Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a verification link to:\n$email\n\nPlease click the link in your inbox to activate your Lifeline profile.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: Check your Spam / Junk folder if you do not see the email. If using a test email address (e.g. @example.com), use Skip Verification below.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: "I've Verified My Email",
                isLoading: isLoading,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).checkVerificationStatus();
                },
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: 'Resend Verification Email',
                backgroundColor: Colors.white,
                textColor: AppColors.primary,
                isLoading: isLoading,
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).resendVerificationEmail();
                },
              ),
              const SizedBox(height: 14),
              TextButton.icon(
                icon: const Icon(Icons.flash_on, color: AppColors.secondary, size: 18),
                label: const Text(
                  'Skip Verification (Dev / Demo Mode)',
                  style: TextStyle(color: AppColors.secondary, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).bypassVerification();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
