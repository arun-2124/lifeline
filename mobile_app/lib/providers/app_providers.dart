import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_app/repositories/auth_repository.dart';
import 'package:mobile_app/repositories/auth_repository_impl.dart';
import 'package:mobile_app/repositories/community_sharing_repository.dart';
import 'package:mobile_app/repositories/community_sharing_repository_impl.dart';
import 'package:mobile_app/repositories/donation_repository.dart';
import 'package:mobile_app/repositories/donation_repository_impl.dart';
import 'package:mobile_app/repositories/ngo_repository.dart';
import 'package:mobile_app/repositories/ngo_repository_impl.dart';
import 'package:mobile_app/repositories/tracking_repository.dart';
import 'package:mobile_app/repositories/tracking_repository_impl.dart';
import 'package:mobile_app/repositories/volunteer_repository.dart';
import 'package:mobile_app/repositories/volunteer_repository_impl.dart';
import 'package:mobile_app/repositories/wallet_repository.dart';
import 'package:mobile_app/repositories/wallet_repository_impl.dart';
import 'package:mobile_app/services/firebase_auth_service.dart';
import 'package:mobile_app/services/firestore_service.dart';
import 'package:mobile_app/services/firebase_storage_service.dart';
import 'package:mobile_app/services/fcm_notification_service.dart';
import 'package:mobile_app/services/ai_service.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/providers/community_sharing_provider.dart';
import 'package:mobile_app/providers/donation_provider.dart';
import 'package:mobile_app/providers/ngo_provider.dart';
import 'package:mobile_app/providers/tracking_provider.dart';
import 'package:mobile_app/providers/volunteer_provider.dart';
import 'package:mobile_app/providers/wallet_provider.dart';

final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthServiceImpl();
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreServiceImpl();
});

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageServiceImpl();
});

final fcmNotificationServiceProvider = Provider<FcmNotificationService>((ref) {
  return FcmNotificationServiceImpl();
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiServiceImpl();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.watch(firebaseAuthServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authRepository: ref.watch(authRepositoryProvider),
  );
});

final donationRepositoryProvider = Provider<DonationRepository>((ref) {
  return DonationRepositoryImpl(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final donationNotifierProvider = StateNotifierProvider<DonationNotifier, DonationState>((ref) {
  return DonationNotifier(
    repository: ref.watch(donationRepositoryProvider),
  );
});

final ngoRepositoryProvider = Provider<NgoRepository>((ref) {
  return NgoRepositoryImpl(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final ngoNotifierProvider = StateNotifierProvider<NgoNotifier, NgoState>((ref) {
  return NgoNotifier(
    repository: ref.watch(ngoRepositoryProvider),
  );
});

final volunteerRepositoryProvider = Provider<VolunteerRepository>((ref) {
  return VolunteerRepositoryImpl(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final volunteerNotifierProvider = StateNotifierProvider<VolunteerNotifier, VolunteerState>((ref) {
  return VolunteerNotifier(
    repository: ref.watch(volunteerRepositoryProvider),
  );
});

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepositoryImpl(
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

final trackingNotifierProvider = StateNotifierProvider<TrackingNotifier, TrackingState>((ref) {
  return TrackingNotifier(
    repository: ref.watch(trackingRepositoryProvider),
  );
});

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  return WalletRepositoryImpl();
});

final walletNotifierProvider = StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  return WalletNotifier(
    ref.watch(walletRepositoryProvider),
  );
});

final communitySharingRepositoryProvider = Provider<CommunitySharingRepository>((ref) {
  return CommunitySharingRepositoryImpl();
});

final communitySharingNotifierProvider = StateNotifierProvider<CommunitySharingNotifier, CommunitySharingState>((ref) {
  return CommunitySharingNotifier(
    ref.watch(communitySharingRepositoryProvider),
  );
});
