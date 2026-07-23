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
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        return ApiResult.failure(
          const AuthFailure(message: 'Failed to create user. Please try again.'),
        );
      }

      await user.updateDisplayName(fullName);

      final userModel = UserModel(
        uid: user.uid,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phoneNumber.trim(),
        role: role,
        verificationStatus: 'pending',
        accountStatus: 'ACTIVE',
        createdAt: DateTime.now(),
        isEmailVerified: user.emailVerified,
      );

      await _firestoreService.setDocument(
        collection: AppConstants.usersCollection,
        docId: user.uid,
        data: userModel.toMap(),
      );

      await _authService.sendEmailVerification();

      AppLogger.i('User registered successfully: ${user.uid} with role: $role');
      return ApiResult.success(userModel);
    } on FirebaseAuthException catch (e) {
      AppLogger.e('FirebaseAuthException during signUp', e);
      return ApiResult.failure(AuthFailure(message: _mapFirebaseAuthError(e)));
    } catch (e, st) {
      AppLogger.e('Unexpected error during signUp', e, st);
      return ApiResult.failure(
        ServerFailure(message: 'An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<UserModel>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
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

      final profileResult = await getUserProfile(uid: user.uid);
      if (profileResult is ApiSuccess<UserModel>) {
        final fetchedUser = profileResult.data.copyWith(
          isEmailVerified: user.emailVerified,
        );
        return ApiResult.success(fetchedUser);
      } else {
        final fallbackUser = UserModel(
          uid: user.uid,
          fullName: user.displayName ?? '',
          email: user.email ?? '',
          phoneNumber: user.phoneNumber ?? '',
          role: 'Donor',
          createdAt: DateTime.now(),
          isEmailVerified: user.emailVerified,
        );
        return ApiResult.success(fallbackUser);
      }
    } on FirebaseAuthException catch (e) {
      AppLogger.e('FirebaseAuthException during signIn', e);
      return ApiResult.failure(AuthFailure(message: _mapFirebaseAuthError(e)));
    } catch (e, st) {
      AppLogger.e('Unexpected error during signIn', e, st);
      return ApiResult.failure(
        ServerFailure(message: 'An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<void>> sendPasswordResetEmail({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email: email);
      return ApiResult.success(null);
    } on FirebaseAuthException catch (e) {
      return ApiResult.failure(AuthFailure(message: _mapFirebaseAuthError(e)));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Failed to send password reset email: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<void>> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
      return ApiResult.success(null);
    } on FirebaseAuthException catch (e) {
      return ApiResult.failure(AuthFailure(message: _mapFirebaseAuthError(e)));
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Failed to send verification email: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<bool>> checkEmailVerified() async {
    try {
      await _authService.reloadUser();
      final isVerified = _authService.currentUser?.emailVerified ?? false;
      
      if (isVerified && _authService.currentUser != null) {
        await _firestoreService.updateDocument(
          collection: AppConstants.usersCollection,
          docId: _authService.currentUser!.uid,
          data: {'isEmailVerified': true},
        );
      }
      
      return ApiResult.success(isVerified);
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Failed to verify email status: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<UserModel>> getUserProfile({required String uid}) async {
    try {
      final doc = await _firestoreService.getDocument(
        collection: AppConstants.usersCollection,
        docId: uid,
      );

      if (doc.exists && doc.data() != null) {
        final userModel = UserModel.fromMap(doc.data()!);
        return ApiResult.success(userModel);
      } else {
        return ApiResult.failure(
          const CacheFailure(message: 'User profile document not found.'),
        );
      }
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Failed to fetch user profile: ${e.toString()}'),
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
      final updateData = <String, dynamic>{
        'fullName': fullName.trim(),
        'phoneNumber': phoneNumber.trim(),
        // ignore: use_null_aware_elements
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      await _firestoreService.updateDocument(
        collection: AppConstants.usersCollection,
        docId: uid,
        data: updateData,
      );

      if (_authService.currentUser?.uid == uid) {
        await _authService.currentUser!.updateDisplayName(fullName.trim());
      }

      final profileResult = await getUserProfile(uid: uid);
      if (profileResult is ApiSuccess<UserModel>) {
        return ApiResult.success(profileResult.data);
      } else {
        return ApiResult.failure(
          const ServerFailure(message: 'Profile updated but failed to refresh user state.'),
        );
      }
    } catch (e) {
      AppLogger.e('Failed to update user profile', e);
      return ApiResult.failure(
        ServerFailure(message: 'Failed to update profile: ${e.toString()}'),
      );
    }
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await _authService.signOut();
      return ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(
        ServerFailure(message: 'Failed to sign out: ${e.toString()}'),
      );
    }
  }

  String _mapFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
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
      default:
        return e.message ?? 'Authentication failed. Code: ${e.code}';
    }
  }
}
