import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FcmNotificationService {
  Future<void> initialize();
  Future<String?> getToken();
}

class FcmNotificationServiceImpl implements FcmNotificationService {
  final FirebaseMessaging _fcm;

  FcmNotificationServiceImpl({FirebaseMessaging? fcm})
      : _fcm = fcm ?? FirebaseMessaging.instance;

  @override
  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        // Handle foreground notifications
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        // Handle background notification clicks
      });
    }
  }

  @override
  Future<String?> getToken() async {
    return await _fcm.getToken();
  }
}
