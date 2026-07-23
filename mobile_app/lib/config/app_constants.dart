class AppConstants {
  static const String appName = 'Lifeline';
  static const String appVersion = '1.0.0';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String notificationsCollection = 'notifications';

  // Storage Buckets / Paths
  static const String profileImagesPath = 'profile_images';

  // API Endpoints (FastAPI integration)
  static const String baseUrl = 'http://10.0.2.2:8000/v1'; // Local dev FastAPI
}
