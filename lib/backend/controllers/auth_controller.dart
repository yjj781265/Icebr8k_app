import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/ib_auth_service.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';

class AuthController extends GetxController {
  late StreamSubscription _fbAuthSub;
  final isSignedIn = false.obs;
  final isSigningIn = false.obs;
  final isSigningInViaThirdParty = false.obs;
  final isSigningUp = false.obs;
  final _ibAuthService = IbAuthService();

  @override
  void onReady() {
    super.onReady();
    _fbAuthSub = _ibAuthService.listenToAuthStateChanges().listen((user) {
      if (user == null) {
        isSignedIn.value = false;
        print('User is signed out!');
      } else {
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
    try {
      isSigningIn.value = true;
      final UserCredential userCredential =
          await _ibAuthService.signInViaEmail(email, password);
      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
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
      } else {
        print('to Home Page');
      }
    } on FirebaseAuthException catch (e) {
      print(e.message);
      Get.dialog(IbSimpleDialog(
          message: e.message.toString(), positiveBtnTrKey: 'ok'));
    } catch (e) {
      Get.dialog(IbSimpleDialog(message: e.toString(), positiveBtnTrKey: 'ok'));
    } finally {
      isSigningIn.value = false;
    }
  }

  Future signUpViaEmail(String email, String password) async {
    try {
      isSigningUp.value = true;
      final UserCredential userCredential =
          await _ibAuthService.signUpViaEmail(email, password);
      final user = userCredential.user;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _ibAuthService.signOut();
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
        print('to Home Page');
      }
    } on FirebaseAuthException catch (e) {
      Get.dialog(IbSimpleDialog(
          message: e.message.toString(), positiveBtnTrKey: 'ok'));
    } catch (e) {
      Get.dialog(IbSimpleDialog(message: e.toString(), positiveBtnTrKey: 'ok'));
    } finally {
      isSigningUp.value = false;
    }
  }

  Future<void> signInViaGoogle() async {
    final credential = await _ibAuthService.signInWithGoogle();
    if (credential.user != null) {
      print(credential.user!.email);
      print(credential.user?.displayName);
    }
  }

  Future<void> signInViaApple() async {
    final credential = await _ibAuthService.signInWithApple();
    if (credential.user != null) {
      print(credential.user!.email);
      print(credential.user?.displayName);
    }
  }

  Future<void> signOut() async {
    await _ibAuthService.signOut();
  }
}
