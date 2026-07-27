import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/core/constants/app_colors.dart';
import 'package:mobile_app/core/constants/app_strings.dart';
import 'package:mobile_app/providers/app_providers.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/utils/app_logger.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _waitForAuthAndNavigate();
  }

  Future<void> _waitForAuthAndNavigate() async {
    const maxWait = Duration(seconds: 5);
    const pollInterval = Duration(milliseconds: 300);
    final deadline = DateTime.now().add(maxWait);

    await Future.delayed(const Duration(milliseconds: 1500));

    while (DateTime.now().isBefore(deadline) && mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.status != AuthStatus.initial) {
        AppLogger.d('SPLASH: Auth resolved to ${authState.status} — navigating');
        _navigateBasedOnStatus(authState);
        return;
      }
      await Future.delayed(pollInterval);
    }

    if (mounted && !_hasNavigated) {
      AppLogger.d('SPLASH: Auth timeout — navigating to welcome');
      _navigateBasedOnStatus(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  void _navigateBasedOnStatus(AuthState state) {
    if (!mounted || _hasNavigated) return;
    _hasNavigated = true;

    switch (state.status) {
      case AuthStatus.authenticated:
        final role = state.user?.role ?? 'Donor';
        AppLogger.d('SPLASH: Navigating to home for role: $role');
        Navigator.of(context).pushReplacementNamed(
          AppRouter.getHomeRouteForRole(role),
        );
        break;
      case AuthStatus.emailVerificationPending:
        AppLogger.d('SPLASH: Navigating to email verification');
        Navigator.of(context).pushReplacementNamed(
          AppRouter.emailVerificationRoute,
        );
        break;
      case AuthStatus.unauthenticated:
      case AuthStatus.error:
      case AuthStatus.initial:
      case AuthStatus.loading:
        AppLogger.d('SPLASH: Navigating to welcome');
        Navigator.of(context).pushReplacementNamed(
          AppRouter.welcomeRoute,
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status != AuthStatus.initial && !_hasNavigated) {
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
