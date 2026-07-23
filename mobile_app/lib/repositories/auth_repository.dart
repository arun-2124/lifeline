import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_app/core/network/api_result.dart';
import 'package:mobile_app/models/user_model.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  
  Future<ApiResult<UserModel>> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
    required String role,
  });

  Future<ApiResult<UserModel>> signInWithEmail({
    required String email,
    required String password,
  });

  Future<ApiResult<void>> sendPasswordResetEmail({required String email});
  Future<ApiResult<void>> sendEmailVerification();
  Future<ApiResult<bool>> checkEmailVerified();
  Future<ApiResult<UserModel>> getUserProfile({required String uid});
  Future<ApiResult<UserModel>> updateUserProfile({
    required String uid,
    required String fullName,
    required String phoneNumber,
    String? photoUrl,
  });
  Future<ApiResult<void>> signOut();
}
