import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/config/app_constants.dart';
import 'package:mobile_app/core/errors/failures.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/user_model.dart';
import 'package:mobile_app/repositories/auth_repository.dart';
import 'package:mobile_app/services/firebase_auth_service.dart';
import 'package:mobile_app/services/firestore_service.dart';
import 'package:mobile_app/utils/app_logger.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthRepositoryImpl({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  @override
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  @override
  User? get currentUser => _authService.currentUser;

  @override
  Future<ApiResult<UserModel>> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  }) async {
    try {
      AppLogger.d('AUTH: Starting registration for $email with role: $role');

      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );
      AppLogger.d('AUTH: Firebase Auth user created: ${credential.user?.uid}');

      final user = credential.user;
      if (user == null) {
        return ApiResult.failure(
          const AuthFailure(message: 'Failed to create user. Please try again.'),
        );
      }

      await user.updateDisplayName(fullName);
      AppLogger.d('AUTH: Display name updated to: $fullName');

      final userModel = UserModel(
        uid: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        role: role,
        verificationStatus: 'pending',
        accountStatus: 'ACTIVE',
        createdAt: DateTime.now(), // Local placeholder; Firestore uses server timestamp
        isEmailVerified: user.emailVerified,
      );

      try {
        await _firestoreService.setDocument(
          collection: AppConstants.usersCollection,
          docId: user.uid,
          data: userModel.toMap(),
        );
        AppLogger.d('AUTH: Firestore user document created for ${user.uid}');
      } on FirebaseException catch (e) {
        AppLogger.e('AUTH: Firestore write FAILED during registration', e);
        // Auth user was created but Firestore doc failed.
        // Don't leave orphan Auth users — delete and report error.
        try {
          await user.delete();
          AppLogger.d('AUTH: Cleaned up orphan Auth user ${user.uid}');
        } catch (deleteError) {
          AppLogger.e('AUTH: Failed to clean up orphan Auth user', deleteError);
        }
        return ApiResult.failure(
          AuthFailure(message: 'Registration failed: ${_mapFirestoreError(e)}'),
        );
      }

      try {
        await _authService.sendEmailVerification();
        AppLogger.d('AUTH: Verification email sent to $email');
      } catch (e) {
        // Non-fatal: user can resend later
        AppLogger.e('AUTH: Failed to send verification email (non-fatal)', e);
      }

      AppLogger.i('AUTH: User registered successfully: ${user.uid} with role: $role');
      return ApiResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      AppLogger.e('AUTH: FirebaseAuthException during signUp: ${e.code}', e);
      return ApiResult.failure(AuthFailure(message: _mapFirebaseAuthError(e)));
    } catch (e, st) {
      AppLogger.e('AUTH: Unexpected error during signUp', e, st);
      return ApiResult.failure(
        ServerFailure(message: 'Registration failed. Please check your connection and try again.'),
      );
    }
  }

  @override
  Future<ApiResult<UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.d('AUTH: Starting login for $email');

      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return ApiResult.failure(
          const AuthFailure(message: 'Login failed. User account not found.'),
        );
      }
      AppLogger.d('AUTH: Firebase Auth login successful: ${user.uid}');

      final profileResult = await getUserProfile(uid: user.uid);
      if (profileResult is ApiSuccess<UserModel>) {
        AppLogger.d('AUTH: Firestore profile loaded. Role: ${profileResult.data.role}');
        final fetchedUser = profileResult.data.copyWith(
          isEmailVerified: user.emailVerified,
        );
        return ApiResult.success(fetchedUser);
      } else {
        AppLogger.e('AUTH: Firestore profile NOT found for ${user.uid}. Using fallback.');
        // Profile not found — this can happen if registration Firestore write failed
        // Create a fallback user, but also try to recreate the Firestore document
        final fallbackUser = UserModel(
          uid: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          role: 'Donor',
          createdAt: DateTime.now(),
          isEmailVerified: user.emailVerified,
        );

        // Attempt to create missing Firestore document
        try {
          await _firestoreService.setDocument(
            collection: AppConstants.usersCollection,
            docId: user.uid,
            data: fallbackUser.toMap(),
          );
          AppLogger.d('AUTH: Created missing Firestore document for ${user.uid}');
        } catch (e) {
          AppLogger.e('AUTH: Failed to create missing Firestore document', e);
        }

        return ApiResult.success(fallbackUser);
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.e('AUTH: FirebaseAuthException during signIn: ${e.code}', e);
      return ApiResult.failure(AuthFailure(message: _mapFirebaseAuthError(e)));
    } catch (e, st) {
      AppLogger.e('AUTH: Unexpected error during signIn', e, st);
      return ApiResult.failure(
        ServerFailure(message: 'Login failed. Please check your connection and try again.'),
      );
    }
  }

  @override
  Future<ApiResult<void>> sendPasswordResetEmail({required String email}) async {
    try {
      AppLogger.d('AUTH: Sending password reset to $email');
      await _authService.sendPasswordResetEmail(email: email);
      AppLogger.i('AUTH: Password reset email sent to $email');
      return ApiResult.success(null);
    } on FirebaseAuthException catch (e) {
      AppLogger.e('AUTH: Password reset failed: ${e.code}', e);
      return ApiResult.failure(AuthFailure(message: _mapFirebaseAuthError(e)));
    } catch (e) {
      AppLogger.e('AUTH: Unexpected error during password reset', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to send password reset email. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<void>> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      AppLogger.i('AUTH: Verification email resent');
      return ApiResult.success(null);
    } on FirebaseAuthException catch (e) {
      return ApiResult.failure(AuthFailure(message: _mapFirebaseAuthError(e)));
    } catch (e) {
      AppLogger.e('AUTH: Failed to send verification email', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to send verification email. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<bool>> checkEmailVerified() async {
    try {
      await _authService.reloadUser();
      final isVerified = _authService.currentUser?.emailVerified ?? false;
      AppLogger.d('AUTH: Email verification status: $isVerified');

      if (isVerified && _authService.currentUser != null) {
        try {
          await _firestoreService.updateDocument(
            collection: AppConstants.usersCollection,
            docId: _authService.currentUser!.uid,
            data: {
              'isEmailVerified': true,
              'updatedAt': FieldValue.serverTimestamp(),
            },
          );
          AppLogger.d('AUTH: Firestore isEmailVerified updated to true');
        } on FirebaseException catch (e) {
          // Non-fatal: the Auth state is the source of truth for email verification
          AppLogger.e('AUTH: Failed to update Firestore isEmailVerified (non-fatal)', e);
        }
      }

      return ApiResult.success(isVerified);
    } catch (e) {
      AppLogger.e('AUTH: Failed to check email verification status', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to verify email status. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<UserModel>> getUserProfile({required String uid}) async {
    try {
      AppLogger.d('AUTH: Fetching Firestore profile for $uid');
      final doc = await _firestoreService.getDocument(
        collection: AppConstants.usersCollection,
        docId: uid,
      );

      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromMap(doc.data()!);
        AppLogger.d('AUTH: Profile loaded — role: ${userModel.role}, status: ${userModel.accountStatus}');
        return ApiResult.success(userModel);
      } else {
        AppLogger.e('AUTH: User profile document NOT found for $uid');
        return ApiResult.failure(
          const CacheFailure(message: 'User profile not found. Please contact support.'),
        );
      }
    } on FirebaseException catch (e) {
      AppLogger.e('AUTH: Firestore error fetching profile: ${e.code}', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to load profile: ${_mapFirestoreError(e)}'),
      );
    } catch (e) {
      AppLogger.e('AUTH: Unexpected error fetching profile', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to load your profile. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<UserModel>> updateUserProfile({
    required String uid,
    required String fullName,
    required String phoneNumber,
    String? photoUrl,
  }) async {
    try {
      AppLogger.d('AUTH: Updating profile for $uid');
      final updateData = <String, dynamic>{
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
        // ignore: use_null_aware_elements
        if (photoUrl != null) 'photoUrl': photoUrl,

      };

      await _firestoreService.updateDocument(
        collection: AppConstants.usersCollection,
        docId: uid,
        data: updateData,
      );
      AppLogger.d('AUTH: Firestore profile updated for $uid');

      if (_authService.currentUser?.uid == uid) {
        await _authService.currentUser!.updateDisplayName(fullName.trim());
      }

      final profileResult = await getUserProfile(uid: uid);
      if (profileResult is ApiSuccess<UserModel>) {
        return ApiResult.success(profileResult.data);
      } else {
        return ApiResult.failure(
          const ServerFailure(message: 'Profile updated but failed to refresh. Please reload.'),
        );
      }
    } on FirebaseException catch (e) {
      AppLogger.e('AUTH: Firestore update failed: ${e.code}', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to update profile: ${_mapFirestoreError(e)}'),
      );
    } catch (e) {
      AppLogger.e('AUTH: Unexpected error updating profile', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to update profile. Please try again.'),
      );
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      AppLogger.d('AUTH: Signing out');
      await _authService.signOut();
      AppLogger.i('AUTH: Sign out successful');
      return ApiResult.success(null);
    } catch (e) {
      AppLogger.e('AUTH: Sign out failed', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to sign out. Please try again.'),
      );
    }
  }

  /// Maps Firebase Auth error codes to user-friendly messages.
  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'Invalid email or password. Please check your credentials.';
      case 'email-already-in-use':
        return 'An account with this email address already exists.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'weak-password':
        return 'The password is too weak. Please use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network connection failed. Please check your internet connection.';
      case 'operation-not-allowed':
        return 'Email/password login is not enabled. Please contact support.';
      case 'requires-recent-login':
        return 'This operation requires recent authentication. Please log in again.';
      default:
        AppLogger.e('AUTH: Unmapped Firebase Auth error code: ${e.code}');
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  /// Maps Firestore error codes to user-friendly messages.
  String _mapFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Access denied. Your account may not have the required permissions.';
      case 'not-found':
        return 'The requested data was not found.';
      case 'already-exists':
        return 'This record already exists.';
      case 'unavailable':
        return 'Service temporarily unavailable. Please try again.';
      case 'deadline-exceeded':
        return 'Request timed out. Please check your connection.';
      default:
        AppLogger.e('AUTH: Unmapped Firestore error code: ${e.code}');
        return e.message ?? 'A database error occurred. Please try again.';
    }
  }
}
