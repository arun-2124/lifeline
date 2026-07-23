import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:mobile_app/core/constants/app_strings.dart';
import 'package:mobile_app/core/services/navigation_service.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/firebase_options.dart';
import 'package:mobile_app/routes/app_router.dart';
import 'package:mobile_app/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppLogger.i('Firebase initialized successfully for Lifeline.');

    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        // ignore: deprecated_member_use
        androidProvider: AndroidProvider.debug,
        // ignore: deprecated_member_use
        appleProvider: AppleProvider.debug,
      );
      AppLogger.i('Firebase App Check activated in Debug mode.');
    }
  } catch (e, st) {
    AppLogger.e('Failed to initialize Firebase / App Check', e, st);
  }

  runApp(
    const ProviderScope(
      child: LifelineApp(),
    ),
  );
}

class LifelineApp extends StatelessWidget {
  const LifelineApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: AppRouter.splashRoute,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
