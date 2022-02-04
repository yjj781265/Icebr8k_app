import 'package:firebase_auth/firebase_auth.dart';

class IbAuthService {
  static final IbAuthService _authService = IbAuthService._();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  factory IbAuthService() {
    return _authService;
  }

  IbAuthService._();

  Future<UserCredential> signInViaEmail(String email, String password) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpViaEmail(String email, String password) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Stream<User?> listenToAuthStateChanges() {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> resetPassword(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
