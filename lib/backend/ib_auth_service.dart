import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final AuthService _authService = AuthService._();
  final FirebaseAuth _fbAuth = FirebaseAuth.instance;

  factory AuthService() {
    return _authService;
  }

  AuthService._();

  Future<UserCredential> signInViaEmail(String email, String password) {
    return _fbAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUpViaEmail(String email, String password) {
    return _fbAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Stream<User?> listenToAuthStateChanges() {
    return _fbAuth.authStateChanges();
  }
}
