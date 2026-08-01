import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/user_model.dart';
import 'package:mobile_app/repositories/auth_repository.dart';
import 'package:mobile_app/utils/app_logger.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailVerificationPending,
  error,
}

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final String? infoMessage;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.infoMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    String? infoMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
      infoMessage: infoMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthNotifier({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(AuthState.initial()) {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authStateSubscription?.cancel();
    _authStateSubscription = _authRepository.authStateChanges.listen((firebaseUser) async {
      if (firebaseUser == null) {
        AppLogger.d('AUTH_PROVIDER: Auth state changed — user signed out');
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      } else {
        AppLogger.d('AUTH_PROVIDER: Auth state changed — user: ${firebaseUser.uid}, emailVerified: ${firebaseUser.emailVerified}');
        try {
          final result = await _authRepository.getUserProfile(uid: firebaseUser.uid);
          if (result is ApiSuccess<UserModel>) {
            final userModel = result.data.copyWith(isEmailVerified: firebaseUser.emailVerified);
            if (!firebaseUser.emailVerified) {
              state = state.copyWith(
                status: AuthStatus.emailVerificationPending,
                user: userModel,
              );
            } else {
              state = state.copyWith(
                status: AuthStatus.authenticated,
                user: userModel,
              );
            }
            AppLogger.d('AUTH_PROVIDER: State set to ${state.status}, role: ${userModel.role}');
          } else {
            final fallbackUser = UserModel(
              uid: firebaseUser.uid,
              fullName: firebaseUser.displayName ?? '',
              email: firebaseUser.email ?? '',
              phoneNumber: firebaseUser.phoneNumber ?? '',
              role: 'Donor',
              createdAt: DateTime.now(),
              isEmailVerified: firebaseUser.emailVerified,
            );
            state = state.copyWith(
              status: firebaseUser.emailVerified
                  ? AuthStatus.authenticated
                  : AuthStatus.emailVerificationPending,
              user: fallbackUser,
            );
          }
        } catch (e, st) {
          AppLogger.e('AUTH_PROVIDER: Error in auth state listener', e, st);
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Failed to load profile. Please try again.',
          );
        }
      }
    });
  }

  Future<void> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      infoMessage: null,
    );

    final result = await _authRepository.signUpWithEmail(
      fullName: fullName,
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      role: role,
    );

    if (result is ApiSuccess<UserModel>) {
      state = state.copyWith(
        status: AuthStatus.emailVerificationPending,
        user: result.data,
        infoMessage: 'Verification email sent. Please check your inbox.',
      );
    } else if (result is ApiFailure<UserModel>) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.failure.message,
      );
    }
  }

  Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      infoMessage: null,
    );

    final result = await _authRepository.signInWithEmail(
      email: email,
      password: password,
    );

    if (result is ApiSuccess<UserModel>) {
      final user = result.data;
      if (!user.isEmailVerified) {
        state = state.copyWith(
          status: AuthStatus.emailVerificationPending,
          user: user,
          infoMessage: 'Please verify your email before continuing.',
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      }
    } else if (result is ApiFailure<UserModel>) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.failure.message,
      );
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      infoMessage: null,
    );

    final result = await _authRepository.sendPasswordResetEmail(email: email);

    if (result is ApiSuccess<void>) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        infoMessage: 'Password reset link sent to $email.',
      );
    } else if (result is ApiFailure<void>) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.failure.message,
      );
    }
  }

  Future<void> resendVerificationEmail() async {
    final result = await _authRepository.sendEmailVerification();
    if (result is ApiSuccess<void>) {
      state = state.copyWith(
        infoMessage: 'Verification email resent successfully.',
      );
    } else if (result is ApiFailure<void>) {
      state = state.copyWith(
        errorMessage: result.failure.message,
      );
    }
  }

  Future<void> checkVerificationStatus() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      infoMessage: null,
    );
    final result = await _authRepository.checkEmailVerified();

    if (result is ApiSuccess<bool>) {
      if (result.data) {
        final currentUid = _authRepository.currentUser?.uid;
        if (currentUid != null) {
          final profileResult = await _authRepository.getUserProfile(uid: currentUid);
          if (profileResult is ApiSuccess<UserModel>) {
            state = state.copyWith(
              status: AuthStatus.authenticated,
              user: profileResult.data.copyWith(isEmailVerified: true),
              infoMessage: 'Email verified successfully!',
            );
            return;
          }
        }
      }
      state = state.copyWith(
        status: AuthStatus.emailVerificationPending,
        errorMessage: 'Email is not verified yet. Please check your inbox and click the link.',
      );
    } else if (result is ApiFailure<bool>) {
      state = state.copyWith(
        status: AuthStatus.emailVerificationPending,
        errorMessage: result.failure.message,
      );
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phoneNumber,
    String? photoUrl,
  }) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      infoMessage: null,
    );

    final result = await _authRepository.updateUserProfile(
      uid: currentUser.uid,
      fullName: fullName,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
    );

    if (result is ApiSuccess<UserModel>) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: result.data,
        infoMessage: 'Profile updated successfully!',
      );
    } else if (result is ApiFailure<UserModel>) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        errorMessage: result.failure.message,
      );
    }
  }

  Future<void> logout() async {
    state = state.copyWith(
      status: AuthStatus.loading,
      errorMessage: null,
      infoMessage: null,
    );
    final result = await _authRepository.signOut();
    if (result is ApiSuccess<void>) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
      );
    } else if (result is ApiFailure<void>) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: result.failure.message,
      );
    }
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
