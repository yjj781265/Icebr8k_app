import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/user_controllers/setup_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/admin/admin_main_page.dart';
import 'package:icebr8k/frontend/admin/role_select_page.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/main_page.dart';
import 'package:icebr8k/frontend/ib_pages/review_page.dart';
import 'package:icebr8k/frontend/ib_pages/setup_pages/setup_page_one.dart';
import 'package:icebr8k/frontend/ib_pages/welcome_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

import '../../services/user_services/ib_auth_service.dart';
import '../../services/user_services/ib_cloud_messaging_service.dart';
import '../../services/user_services/ib_local_data_service.dart';
import '../../services/user_services/ib_user_db_service.dart';

class AuthController extends GetxService {
  final isInitializing = true.obs;
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
        Get.offAll(() => WelcomePage(),
            transition: Transition.circularReveal,
            duration: const Duration(
                milliseconds: IbConfig.kEventTriggerDelayInMillis));
        isInitializing.value = true;
        return;
      } else {
        firebaseUser = user;
        print('User is signed in!');
        if (isInitializing.isTrue) {
          _navigateToCorrectPage();
        }
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    _fbAuthSub.cancel();
    print('auth controller onClose');
  }

  Future signInViaEmail(
      {required String email,
      required String password,
      required bool rememberEmail}) async {
    Get.dialog(
      const IbLoadingDialog(messageTrKey: 'signing_in'),
      barrierDismissible: false,
    );
    try {
      isSigningIn.value = true;

      if (rememberEmail) {
        IbLocalDataService()
            .updateStringValue(key: StorageKey.loginEmailString, value: email);
      } else {
        IbLocalDataService().removeKey(StorageKey.loginEmailString);
      }

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
            showNegativeBtn: false,
            actionButtons: TextButton(
              onPressed: () async {
                try {
                  await user.sendEmailVerification();
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
      } else if (firebaseUser != null && firebaseUser!.emailVerified) {
        _navigateToCorrectPage();
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
        Get.back();
        Get.dialog(IbDialog(
          title: "Verify your email",
          subtitle: 'sign_up_email_verification'.tr,
          positiveTextKey: 'ok',
          onPositiveTap: () {
            Get.offAll(() => WelcomePage(),
                transition: Transition.circularReveal);
          },
          showNegativeBtn: false,
        ));
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

  Future<void> _navigateToCorrectPage() async {
    try {
      if (firebaseUser != null && firebaseUser!.emailVerified) {
        final IbUser? ibUser =
            await IbUserDbService().queryIbUser(firebaseUser!.uid);

        /// check roles of the user
        if (ibUser != null &&
            ibUser.roles.contains(IbUser.kAdminRole) &&
            ibUser.roles.contains(IbUser.kUserRole)) {
          Get.offAll(() => RoleSelectPage());
          return;
        } else if (ibUser != null && ibUser.roles.contains(IbUser.kAdminRole)) {
          Get.offAll(() => AdminMainPage());
        }

        String? status = '';
        if (ibUser == null) {
          status = null;
        } else {
          status = ibUser.status;
        }

        switch (status) {
          case IbUser.kUserStatusApproved:
            Get.offAll(() => MainPage(),
                binding: HomeBinding(), transition: Transition.circularReveal);
            break;

          case IbUser.kUserStatusBanned:
            //Todo Go to CounterDown Page
            print('Go to CounterDown Page');
            break;

          case IbUser.kUserStatusPending:
            print('Go to InReview Page');
            Get.offAll(() => ReviewPage(),
                transition: Transition.circularReveal);
            break;

          case IbUser.kUserStatusRejected:
            print('Go to Setup Page with note dialog');
            Get.offAll(
                () => SetupPageOne(Get.put(
                    SetupController(status: IbUser.kUserStatusRejected))),
                transition: Transition.circularReveal);
            break;

          case null:
            print('Go to Setup page');
            Get.offAll(() => SetupPageOne(Get.put(SetupController())),
                transition: Transition.circularReveal);
            break;

          default:
            print('default Go to Setup page');
            Get.offAll(() => SetupPageOne(Get.put(SetupController())),
                transition: Transition.circularReveal);
            break;
        }
      } else {
        print('AuthController firebase user email is not verified ');
        Get.offAll(() => WelcomePage(),
            transition: Transition.circularReveal,
            duration: const Duration(
                milliseconds: IbConfig.kEventTriggerDelayInMillis));
      }
    } on FirebaseAuthException catch (e) {
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.message ?? '',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'));
    try {
      await _ibAuthService.resetPassword(email);
      Get.back();
      final String msg = 'reset_email_msg'.trParams({'email': email});
      Get.dialog(IbDialog(
        title: 'Reset Password',
        subtitle: msg,
        positiveTextKey: 'ok',
        showNegativeBtn: false,
      ));
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
    }
    await _ibAuthService.signOut();
  }
}