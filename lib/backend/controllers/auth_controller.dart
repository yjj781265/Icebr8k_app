import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/services/ib_auth_service.dart';
import 'package:icebr8k/backend/services/ib_cloud_messaging_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/welcome_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

class AuthController extends GetxService {
  late StreamSubscription _fbAuthSub;
  final isSigningIn = false.obs;
  final isSigningUp = false.obs;
  User? firebaseUser;
  final _ibAuthService = IbAuthService();

  @override
  void onInit() {
    super.onInit();
    _fbAuthSub = _ibAuthService.listenToAuthStateChanges().listen((user) async {
      if (user == null) {
        firebaseUser = null;
        print('User is signed out!');
      } else {
        firebaseUser = user;
        // get user answered questions and update the login time
        Get.lazyPut(() => MyAnsweredQuestionsController(), fenix: true);
        if (await IbUserDbService().isIbUserExist(firebaseUser!.uid)) {
          IbUserDbService().loginIbUser(
              uid: firebaseUser!.uid,
              loginTimeInMs: DateTime.now().millisecondsSinceEpoch);
        }
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
    Get.dialog(
      const IbLoadingDialog(messageTrKey: 'signing_in'),
      barrierDismissible: false,
    );
    try {
      isSigningIn.value = true;
      final UserCredential userCredential =
          await _ibAuthService.signInViaEmail(email, password);
      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        Get.back();
        Get.dialog(
          IbDialog(
            title: 'Email is not verified',
            subtitle: 'sign_in_email_verification'.tr,
            positiveTextKey: 'ok',
            onPositiveTap: () {
              _ibAuthService.signOut();
            },
            actionButtons: TextButton(
              onPressed: () async {
                try {
                  await user.sendEmailVerification();
                  _ibAuthService.signOut();
                  Get.back();
                  Get.dialog(
                    IbDialog(
                      title: 'Info',
                      subtitle: 'verification_email_sent'.tr,
                      positiveTextKey: 'ok',
                      showNegativeBtn: false,
                      onPositiveTap: () => Get.back(),
                    ),
                  );
                } on FirebaseException catch (e) {
                  Get.back();
                  Get.dialog(
                    IbDialog(
                      title: 'OOPS',
                      subtitle: e.message ?? 'Something is wrong...',
                      positiveTextKey: 'ok',
                      showNegativeBtn: false,
                      onPositiveTap: () => Get.back(),
                    ),
                  );
                }
              },
              child: Text('resend_verification_email'.tr),
            ),
          ),
          barrierDismissible: false,
        );
      } else if (user != null && user.emailVerified) {
        final isIbUserExist = await IbUserDbService().isIbUserExist(user.uid);
        if (isIbUserExist) {
          await IbUserDbService().loginIbUser(
            uid: user.uid,
            loginTimeInMs: DateTime.now().millisecondsSinceEpoch,
          );
          // Todo
        } else {
          // Todo
        }
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.message ?? 'Something went wrong...',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
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

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        _ibAuthService.signOut();
        Get.back();
        Get.dialog(IbDialog(
          title: "Verify your email",
          subtitle: 'sign_up_email_verification'.tr,
          positiveTextKey: 'ok',
          showNegativeBtn: false,
        ));
      } else {
        Get.offAll(() => WelcomePage());
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.message ?? 'Something went wrong...',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
    } finally {
      isSigningUp.value = false;
    }
  }

/*  Future<void> _handleUserFirstLogin(String uid) async {
    final bool isUserNameMissing =
        await IbUserDbService().isUsernameMissing(uid);
    final bool isAvatarUrlMissing =
        await IbUserDbService().isAvatarUrlMissing(uid);
    final questions = await IbUserDbService().queryUnAnsweredFirst8Q(uid);

    Get.back();
    if (questions.isNotEmpty || isUserNameMissing || isAvatarUrlMissing) {
      Get.offAll(
        () => SetupPage(),
        transition: Transition.fadeIn,
      );
    } else {
      Get.offAll(
        () => HomePage(),
        binding: HomeBinding(),
        transition: Transition.fadeIn,
      );
    }
  }*/

  Future<void> resetPassword(String email) async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'));
    try {
      await _ibAuthService.resetPassword(email);
      Get.back();
      final String msg = 'reset_email_msg'.trParams({'email': email});
      Get.dialog(IbDialog(
          title: 'Reset Password', subtitle: msg, positiveTextKey: 'ok'));
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.message ?? 'Something went wrong...',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
    }
  }

  Future<void> signOut() async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'signing_out'));
    if (firebaseUser != null) {
      await IbCloudMessagingService().removeMyToken();
      await IbUserDbService().signOutIbUser(firebaseUser!.uid);
    }
    await _ibAuthService.signOut();
    Get.back();
    Get.offAll(() => WelcomePage(), transition: Transition.fadeIn);
  }
}
