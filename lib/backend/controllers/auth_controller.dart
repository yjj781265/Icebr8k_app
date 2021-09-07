import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/sign_in_controller.dart';
import 'package:icebr8k/backend/controllers/sign_up_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_auth_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/home_page.dart';
import 'package:icebr8k/frontend/ib_pages/set_up_page.dart';
import 'package:icebr8k/frontend/ib_pages/sign_in_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';

class AuthController extends GetxService {
  late StreamSubscription _fbAuthSub;
  final isSigningIn = false.obs;
  final isSigningInViaThirdParty = false.obs;
  final isSigningUp = false.obs;
  User? firebaseUser;
  IbUser? ibUser;
  final _ibAuthService = IbAuthService();

  @override
  void onReady() {
    super.onReady();
    _fbAuthSub = _ibAuthService.listenToAuthStateChanges().listen((user) async {
      if (user == null) {
        firebaseUser = null;
        print('User is signed out!');
      } else {
        firebaseUser = user;
        ibUser = await IbUserDbService().queryIbUser(firebaseUser!.uid);
        print('User is signed in! ${firebaseUser!.uid}');
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    _fbAuthSub.cancel();
    print('auth controller onClose');
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
                      try {
                        await user.sendEmailVerification();
                        _ibAuthService.signOut();
                        Get.back();
                        Get.dialog(IbSimpleDialog(
                          message: 'verification_email_sent'.tr,
                          positiveBtnTrKey: 'ok',
                        ));
                      } on FirebaseException catch (e) {
                        Get.back();
                        Get.dialog(IbSimpleDialog(
                            message: e.message!, positiveBtnTrKey: 'ok'));
                      }
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
          final bool isSetupNeeded =
              await IbUserDbService().isUsernameMissing(firebaseUser!.uid);
          if (isSetupNeeded) {
            Get.offAll(() => SetupPage());
          } else {
            Get.offAll(() => HomePage(), binding: HomeBinding());
          }
        } else {
          Get.dialog(const IbSimpleDialog(
              message: 'User does not exist', positiveBtnTrKey: 'ok'));
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
          Get.dialog(const IbSimpleDialog(
              message: 'User already registered', positiveBtnTrKey: 'ok'));
        } else {
          await IbUserDbService().updateIbUser(
            IbUser(
              id: user.uid,
              birthdateInMs: _controller.birthdateInMs.value,
              joinTimeInMs: DateTime.now().millisecondsSinceEpoch,
              email: _controller.email.value.trim(),
            ),
          );
        }
      }

      if (user != null && !user.emailVerified) {
        try {
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
        } on FirebaseException catch (e) {
          print(e.message);
        }
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
    _handleUserCredential(credential);
  }

  Future<void> signInViaApple() async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'signing_in'));
    final credential = await _ibAuthService.signInWithApple();
    if (credential == null) {
      Get.back();
      return;
    }

    _handleUserCredential(credential);
  }

  Future<void> _handleUserCredential(UserCredential _credential) async {
    final user = _credential.user;
    if (user != null) {
      final _controller = Get.find<SignInController>();
      if (await IbUserDbService().isIbUserExist(user.uid)) {
        await IbUserDbService().loginIbUser(
          uid: user.uid,
          loginTimeInMs: DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        await IbUserDbService().updateIbUser(IbUser(
          id: user.uid,
          email: _credential.user!.email ?? '',
          birthdateInMs: _controller.birthdateInMs.value,
          joinTimeInMs: DateTime.now().millisecondsSinceEpoch,
          loginTimeInMs: DateTime.now().millisecondsSinceEpoch,
        ));
      }
      Get.back();

      final bool isSetupNeeded =
          await IbUserDbService().isUsernameMissing(firebaseUser!.uid);
      if (isSetupNeeded) {
        Get.offAll(() => SetupPage());
      } else {
        Get.offAll(() => HomePage(), binding: HomeBinding());
      }
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
    Get.offAll(() => SignInPage(), transition: Transition.fadeIn);
  }
}
