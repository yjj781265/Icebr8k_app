import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/setup_controller.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_auth_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_db_status_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/admin/admin_main_page.dart';
import 'package:icebr8k/frontend/admin/role_select_page.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/setup_pages/setup_page_one.dart';
import 'package:icebr8k/frontend/ib_pages/welcome_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

import '../../../frontend/ib_pages/main_page.dart';
import '../../../frontend/ib_pages/setup_pages/review_page.dart';
import '../../bindings/home_binding.dart';

class AuthController extends GetxService {
  final isInitializing = true.obs;
  late StreamSubscription _fbAuthSub;
  late StreamSubscription _dbStatusSub;
  final isSigningIn = false.obs;
  final isSigningUp = false.obs;
  bool isAnalyticsEnabled = false;
  User? firebaseUser;
  final _ibAuthService = IbAuthService();

  @override
  void onInit() {
    super.onInit();
    _dbStatusSub = IbDbStatusService().listenToStatus().listen((event) async {
      final isRunning = event.data()!['isRunning'] as bool;
      final note = event.data()!['note'] as String;
      final outDatedMsg = event.data()!['outdatedMsg'] as String;
      final minV = event.data()!['min_v'] as double;
      final isOutdated = IbConfig.kVersion < minV;
      isAnalyticsEnabled = event.data()!['isAnalyticsEnabled'] as bool;
      if (isOutdated) {
        await IbAnalyticsManager().logCustomEvent(
            name: 'app_outdated',
            data: {'note': 'app terminated due to lower version'});
        Get.offAll(() => WelcomePage(), transition: Transition.noTransition);
        Get.dialog(
            IbDialog(
              title: 'App Outdated',
              subtitle: outDatedMsg,
              showNegativeBtn: false,
            ),
            barrierDismissible: false);
        return;
      }

      if (!isRunning) {
        await IbAnalyticsManager().logCustomEvent(
            name: 'server_down',
            data: {'note': 'server is down, user got kicked out'});
        Get.offAll(() => WelcomePage());
        IbUtils.showSimpleSnackBar(
            msg: note,
            backgroundColor: IbColors.primaryColor,
            isPersistent: true);
        return;
      } else {
        Get.closeAllSnackbars();
      }
    });

    _fbAuthSub = _ibAuthService.listenToAuthStateChanges().listen((user) async {
      if (user == null) {
        firebaseUser = null;
        await IbAnalyticsManager()
            .logCustomEvent(name: 'user_log_out', data: {});
        print('User is signed out!');
        isInitializing.value = true;
        Get.offAll(() => WelcomePage(),
            transition: Transition.circularReveal,
            duration: const Duration(
                milliseconds: IbConfig.kEventTriggerDelayInMillis));
        return;
      } else {
        firebaseUser = user;
        print('User is signed in!');
        await IbAnalyticsManager()
            .logCustomEvent(name: 'user_log_in', data: {});
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
    _dbStatusSub.cancel();
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
      await IbAnalyticsManager().logSignIn('signInViaEmail');

      if (rememberEmail) {
        IbLocalDataService()
            .updateStringValue(key: StorageKey.loginEmailString, value: email);
      } else {
        IbLocalDataService().removeKey(StorageKey.loginEmailString);
      }

      final UserCredential userCredential =
          await _ibAuthService.signInViaEmail(email, password);
      firebaseUser = userCredential.user;

      if (firebaseUser != null && !firebaseUser!.emailVerified) {
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
                  await firebaseUser!.sendEmailVerification();
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
      await IbAnalyticsManager().logSignUp('signUpViaEmail');
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
          onPositiveTap: () async {
            await _ibAuthService.signOut();
            Get.offAll(() => WelcomePage(),
                transition: Transition.circularReveal);
          },
          showNegativeBtn: false,
        ));
      } else {
        await _ibAuthService.signOut();
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
      final statusSnap = await IbDbStatusService().queryStatus();
      final isRunning = statusSnap.data()!['isRunning'] as bool;
      final note = statusSnap.data()!['note'] as String;
      final minV = statusSnap.data()!['min_v'] as double;
      final outDatedMsg = statusSnap.data()!['outdatedMsg'] as String;
      final isOutdated = IbConfig.kVersion < minV;

      if (isOutdated) {
        await IbAnalyticsManager().logCustomEvent(
            name: 'app_outdated',
            data: {'note': 'app terminated due to lower version'});
        Get.offAll(() => WelcomePage(), transition: Transition.noTransition);
        await IbAnalyticsManager().logScreenView(
            className: "AuthController", screenName: "WelcomePage");
        Get.dialog(
            IbDialog(
              title: 'App Outdated',
              subtitle: outDatedMsg,
              showNegativeBtn: false,
            ),
            barrierDismissible: false);
        return;
      }

      if (!isRunning) {
        await IbAnalyticsManager().logCustomEvent(
            name: 'server_down',
            data: {'note': 'server is down, user got kicked out'});
        Get.offAll(() => WelcomePage());
        await IbAnalyticsManager().logScreenView(
            className: "AuthController", screenName: "WelcomePage");
        IbUtils.showSimpleSnackBar(
            msg: note,
            backgroundColor: IbColors.primaryColor,
            isPersistent: true);
        return;
      } else {
        Get.closeAllSnackbars();
      }

      final result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) {
        IbUtils.showSimpleSnackBar(
            msg: 'No Internet Connection',
            backgroundColor: IbColors.errorRed,
            isPersistent: true);
      }

      if (firebaseUser != null && firebaseUser!.emailVerified) {
        final IbUser? ibUser =
            await IbUserDbService().queryIbUser(firebaseUser!.uid);

        /// check roles of the user
        if (ibUser != null &&
            ibUser.roles.contains(IbUser.kAdminRole) &&
            ibUser.roles.contains(IbUser.kUserRole)) {
          await IbAnalyticsManager().logScreenView(
              className: "AuthController", screenName: "RoleSelectPage");
          Get.offAll(() => RoleSelectPage());

          return;
        } else if (ibUser != null && ibUser.roles.contains(IbUser.kAdminRole)) {
          await IbAnalyticsManager().logScreenView(
              className: "AuthController", screenName: "AdminMainPage");
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
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "MainPage");
            Get.off(() => MainPage(),
                binding: HomeBinding(ibUser!),
                transition: Transition.circularReveal);
            break;

          case IbUser.kUserStatusBanned:
            //Todo Go to CounterDown Page
            print('Go to CounterDown Page');
            break;

          case IbUser.kUserStatusPending:
            print('Go to InReview Page');
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "ReviewPage");
            Get.offAll(() => ReviewPage(),
                transition: Transition.circularReveal);
            break;

          case IbUser.kUserStatusRejected:
            print('Go to Setup Page with note dialog');
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "SetupPageOne");
            Get.offAll(
                () => SetupPageOne(Get.put(
                    SetupController(status: IbUser.kUserStatusRejected))),
                transition: Transition.circularReveal);
            break;

          case null:
            print('Go to Setup page');
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "SetupPageOne");
            Get.offAll(() => SetupPageOne(Get.put(SetupController())),
                transition: Transition.circularReveal);
            break;

          default:
            print('default Go to Setup page');
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "SetupPageOne");
            Get.offAll(() => SetupPageOne(Get.put(SetupController())),
                transition: Transition.circularReveal);
            break;
        }
      } else {
        print('AuthController firebase user email is not verified ');
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
      await IbAnalyticsManager().logCustomEvent(name: "reset_pwd", data: {});
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
      await IbUserDbService().removeTokenFromDatabase();
    }
    await _ibAuthService.signOut();
  }
}
