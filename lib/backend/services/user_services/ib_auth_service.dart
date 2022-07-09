import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:icebr8k/backend/services/admin_services/ib_admin_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../db_config.dart';

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

  Future<bool> deleteAccount() async {
    if (IbUtils.getCurrentIbUser() == null) {
      return false;
    }
    try {
      await IbAdminDbService().deleteAllEmoPics(IbUtils.getCurrentIbUser()!);
      await IbAdminDbService().deleteAvatarUrl(IbUtils.getCurrentIbUser()!);
      await IbAdminDbService().deleteCoverPhoto(IbUtils.getCurrentIbUser()!);
      await FirebaseFunctions.instance.httpsCallable('deleteAccount').call({
        'dbSuffix': DbConfig.dbSuffix,
        'uid': IbUtils.getCurrentUid() ?? ''
      });
      return true;
    } on FirebaseFunctionsException catch (error) {
      print(error.code);
      print(error.details);
      print(error.message);
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    return _firebaseAuth.sendPasswordResetEmail(email: email);
  }
}
