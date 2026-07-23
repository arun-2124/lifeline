import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/constants/app_strings.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/routes/app_router.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final authState = ref.read(authNotifierProvider);
    _navigateBasedOnStatus(authState);
  }

  void _navigateBasedOnStatus(AuthState state) {
    if (!mounted) return;

    switch (state.status) {
      case AuthStatus.authenticated:
        final role = state.user?.role ?? 'Donor';
        Navigator.of(context).pushReplacementNamed(
          AppRouter.getHomeRouteForRole(role),
        );
        break;
      case AuthStatus.emailVerificationPending:
        Navigator.of(context).pushReplacementNamed(
          AppRouter.emailVerificationRoute,
        );
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      case AuthStatus.initial:
      default:
        Navigator.of(context).pushReplacementNamed(
          AppRouter.welcomeRoute,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (previous?.status != next.status) {
        _navigateBasedOnStatus(next);
      }
    });

    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_rounded, size: 80, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              AppStrings.appName,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.appTagline,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(strokeWidth: 2.5),
          ],
        ),
      ),
    );
  }
}
