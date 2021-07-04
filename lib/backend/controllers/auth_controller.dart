import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/sign_in_controller.dart';
import 'package:icebr8k/backend/controllers/sign_up_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_auth_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/home_page.dart';
import 'package:icebr8k/frontend/ib_pages/sign_in_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';

class AuthController extends GetxController {
  late StreamSubscription _fbAuthSub;
  final isSignedIn = false.obs;
  final isSigningIn = false.obs;
  final isSigningInViaThirdParty = false.obs;
  final isSigningUp = false.obs;
  User? firebaseUser;
  final _ibAuthService = IbAuthService();

  @override
  void onReady() {
    super.onReady();
    _fbAuthSub = _ibAuthService.listenToAuthStateChanges().listen((user) {
      if (user == null) {
        firebaseUser = null;
        isSignedIn.value = false;
        print('User is signed out!');
      } else {
        firebaseUser = user;
        isSignedIn.value = true;
        print('User is signed in!');
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    _fbAuthSub.cancel();
  }

  Future signInViaEmail(String email, String password) async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'signing_in'),
        barrierDismissible: false);
    try {
      isSigningIn.value = true;
      final UserCredential userCredential =
          await _ibAuthService.signInViaEmail(email, password);
      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        Get.back();
        Get.dialog(
            IbSimpleDialog(
              message: 'sign_in_email_verification'.tr,
              positiveBtnTrKey: 'ok',
              positiveBtnEvent: () {
                _ibAuthService.signOut();
              },
              actionButtons: [
                TextButton(
                    onPressed: () async {
                      await user.sendEmailVerification();
                      _ibAuthService.signOut();
                      Get.back();
                      Get.dialog(IbSimpleDialog(
                        message: 'verification_email_sent'.tr,
                        positiveBtnTrKey: 'ok',
                      ));
                    },
                    child: Text('resend_verification_email'.tr))
              ],
            ),
            barrierDismissible: false);
      } else if (user != null && user.emailVerified) {
        final isIbUserExist = await IbUserDbService().isIbUserExist(user.uid);
        if (isIbUserExist) {
          await IbUserDbService().loginIbUser(
            uid: user.uid,
            loginTimeInMs: DateTime.now().millisecondsSinceEpoch,
          );
          Get.offAll(HomePage());
        } else {
          throw UnimplementedError('this should not happen !!');
        }
        Get.back();
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      print(e.message);
      Get.dialog(IbSimpleDialog(
          message: e.message.toString(), positiveBtnTrKey: 'ok'));
    } catch (e) {
      Get.back();
      Get.dialog(IbSimpleDialog(message: e.toString(), positiveBtnTrKey: 'ok'));
    } finally {
      isSigningIn.value = false;
    }
  }

  Future signUpViaEmail(String email, String password) async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'signing_up'),
        barrierDismissible: false);
    try {
      isSigningUp.value = true;
      final UserCredential userCredential =
          await _ibAuthService.signUpViaEmail(email.trim(), password);
      final user = userCredential.user;

      if (user != null) {
        final isIbUserExist = await IbUserDbService().isIbUserExist(user.uid);
        final _controller = Get.find<SignUpController>();

        if (isIbUserExist) {
          Get.back();
          throw UnimplementedError('this should not happen !!');
        } else {
          await IbUserDbService().loginNewIbUser(
            IbUser(
              id: user.uid,
              birthdateInMs: _controller.birthdateInMs.value,
              joinTimeInMs: DateTime.now().millisecondsSinceEpoch,
              name: _controller.name.value,
              email: _controller.email.value.trim(),
            ),
          );
        }
      }

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _ibAuthService.signOut();
        Get.back();
        Get.dialog(
            IbSimpleDialog(
              message: 'sign_up_email_verification'.tr,
              positiveBtnTrKey: 'ok',
              positiveBtnEvent: () {
                Get.back(result: [email, password]);
              },
            ),
            barrierDismissible: false);
      } else {
        throw UnimplementedError('this should not happen !!');
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.dialog(IbSimpleDialog(
          message: e.message.toString(), positiveBtnTrKey: 'ok'));
    } catch (e) {
      Get.back();
      Get.dialog(IbSimpleDialog(message: e.toString(), positiveBtnTrKey: 'ok'));
    } finally {
      isSigningUp.value = false;
    }
  }

  Future<void> signInViaGoogle() async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'signing_in'));
    final credential = await _ibAuthService.signInWithGoogle();
    if (credential == null) {
      Get.back();
      return;
    }
    final user = credential.user;
    if (user != null) {
      final _controller = Get.find<SignInController>();
      if (await IbUserDbService().isIbUserExist(user.uid)) {
        await IbUserDbService().loginIbUser(
          uid: user.uid,
          loginTimeInMs: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        await IbUserDbService().loginNewIbUser(IbUser(
          id: user.uid,
          birthdateInMs: _controller.birthdateInMs.value,
          joinTimeInMs: DateTime.now().millisecondsSinceEpoch,
          loginTimeInMs: DateTime.now().millisecondsSinceEpoch,
          name: user.displayName ?? '',
          email: user.email ?? '',
        ));
      }
      Get.back();
      Get.offAll(HomePage());
    }
  }

  Future<void> signInViaApple() async {
    final credential = await _ibAuthService.signInWithApple();
    if (credential.user != null) {
      print(credential.user!.email);
      print(credential.user?.displayName);
    }
  }

  Future<void> resetPassword(String email) async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'));
    try {
      await _ibAuthService.resetPassword(email);
      Get.back();
      final String msg = 'reset_email_msg'.trParams({'email': email}) ?? '';
      Get.dialog(IbSimpleDialog(message: msg, positiveBtnTrKey: 'ok'));
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.dialog(IbSimpleDialog(
          message: e.message ?? 'error', positiveBtnTrKey: 'ok'));
    }
  }

  Future<void> signOut() async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'signing_out'));
    if (firebaseUser != null) {
      await IbUserDbService().signOutIbUser(firebaseUser!.uid);
    }
    await _ibAuthService.signOut();
    Get.back();
    Get.offAll(SignInPage(), transition: Transition.fadeIn);
  }
}
