import 'package:firebase_auth/firebase_auth.dart';

abstract class FirebaseAuthService {
  Stream<User?> get authStateChanges;
  User? get currentUser;
  Future<UserCredential> signInWithEmail({required String email, required String password});
  Future<UserCredential> signUpWithEmail({required String email, required String password});
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> sendEmailVerification();
  Future<void> reloadUser();
  Future<void> signOut();
}

class FirebaseAuthServiceImpl implements FirebaseAuthService {
  final FirebaseAuth _auth;

  FirebaseAuthServiceImpl({FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<UserCredential> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
