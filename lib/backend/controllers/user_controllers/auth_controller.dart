import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
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
import 'package:icebr8k/frontend/ib_pages/setup_pages/banned_count_down_page.dart';
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
  final IbUtils ibUtils;
  final IbDbStatusService ibDbStatusService;
  final IbLocalDataService ibLocalDataService;
  final IbAuthService ibAuthService;
  late StreamSubscription networkSub;

  AuthController(
      {required this.ibUtils,
      required this.ibAuthService,
      required this.ibDbStatusService,
      required this.ibLocalDataService});

  @override
  void onInit() {
    super.onInit();
    networkSub = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        IbUtils().showSimpleSnackBar(
            msg: 'No Internet Connection',
            backgroundColor: IbColors.errorRed,
            isPersistent: true);
      } else if (result != ConnectivityResult.bluetooth) {
        Get.closeAllSnackbars();
      }
    }, onError: (e) {
      print(e);
    });
    _dbStatusSub = ibDbStatusService.listenToStatus().listen((event) async {
      await _handleDbStatus(event);
      await setUpAnalytics();
    });

    _fbAuthSub = ibAuthService.listenToAuthStateChanges().listen((user) async {
      if (user == null) {
        firebaseUser = null;
        await IbAnalyticsManager()
            .logCustomEvent(name: 'user_log_out', data: {});
        print('User is signed out!');
        isInitializing.value = true;
        ibUtils.offAll(WelcomePage(), transition: Transition.noTransition);
        return;
      } else {
        firebaseUser = user;
        print('User is signed in!');
        await IbAnalyticsManager()
            .logCustomEvent(name: 'user_log_in', data: {});
        navigateToCorrectPage();
      }
    });
  }

  Future<bool> _handleDbStatus(
      DocumentSnapshot<Map<String, dynamic>> snapshot) async {
    final isRunning = snapshot.data()!['isRunning'] as bool;
    final note = snapshot.data()!['note'] as String;
    final minV = double.parse(snapshot.data()!['min_v'].toString());
    final isOutdated = IbConfig.kVersion < minV;
    isAnalyticsEnabled = snapshot.data()!['isAnalyticsEnabled'] as bool;

    if (isOutdated) {
      await IbAnalyticsManager().logCustomEvent(
          name: 'app_outdated',
          data: {'note': 'app terminated due to lower version'});
      ibUtils.offAll(WelcomePage(), transition: Transition.noTransition);
      ibUtils.showDialog(
          const IbDialog(
            title: 'App Outdated',
            subtitle: 'Please update your app to the latest version',
            showNegativeBtn: false,
          ),
          barrierDismissible: false);
      return false;
    }

    if (!isRunning) {
      await IbAnalyticsManager().logCustomEvent(
          name: 'server_down',
          data: {'note': 'server is down, user got kicked out'});
      ibUtils.offAll(WelcomePage(), transition: Transition.noTransition);
      ibUtils.showSimpleSnackBar(
          msg: note,
          backgroundColor: IbColors.primaryColor,
          isPersistent: true);
      return false;
    } else {
      ibUtils.closeAllSnackbars();
    }
    return true;
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    await _fbAuthSub.cancel();
    await _dbStatusSub.cancel();
    await networkSub.cancel();
    print('auth controller onClose');
  }

  Future<void> setUpAnalytics() async {
    final FirebasePerformance performance = FirebasePerformance.instance;
    final FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
    await performance.setPerformanceCollectionEnabled(isAnalyticsEnabled);
    await crashlytics.setCrashlyticsCollectionEnabled(isAnalyticsEnabled);
  }

  Future<void> signInViaEmail(
      {required String email,
      required String password,
      required bool rememberEmail}) async {
    ibUtils.showDialog(
      const IbLoadingDialog(messageTrKey: 'signing_in'),
      barrierDismissible: false,
    );

    try {
      isSigningIn.value = true;
      await IbAnalyticsManager().logSignIn('signInViaEmail');

      if (rememberEmail) {
        ibLocalDataService.updateStringValue(
            key: StorageKey.loginEmailString, value: email);
      } else {
        ibLocalDataService.removeKey(StorageKey.loginEmailString);
      }

      final UserCredential userCredential =
          await ibAuthService.signInViaEmail(email, password);
      firebaseUser = userCredential.user;

      if (firebaseUser != null && !firebaseUser!.emailVerified) {
        Get.back();
        ibUtils.showDialog(
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
                  ibUtils.showDialog(
                    IbDialog(
                      title: 'Info',
                      subtitle: 'verification_email_sent'.tr,
                      positiveTextKey: 'ok',
                      showNegativeBtn: false,
                    ),
                  );
                } on FirebaseException catch (e) {
                  Get.back();
                  ibUtils.showDialog(
                    IbDialog(
                      title: 'OOPS',
                      subtitle: e.message ?? 'Something is wrong...',
                      positiveTextKey: 'ok',
                      showNegativeBtn: false,
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
        navigateToCorrectPage();
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      ibUtils.showDialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.message ?? 'Something went wrong...',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      Get.back();
      ibUtils.showDialog(IbDialog(
        showNegativeBtn: false,
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
    } finally {
      isSigningIn.value = false;
    }
  }

  Future signUpViaEmail(String email, String password) async {
    ibUtils.showDialog(const IbLoadingDialog(messageTrKey: 'signing_up'),
        barrierDismissible: false);
    try {
      isSigningUp.value = true;
      await IbAnalyticsManager().logSignUp('signUpViaEmail');
      final UserCredential userCredential =
          await ibAuthService.signUpViaEmail(email.trim(), password);
      final user = userCredential.user;

      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.back();
        ibUtils.showDialog(IbDialog(
          title: "Verify your email",
          subtitle: 'sign_up_email_verification'.tr,
          positiveTextKey: 'ok',
          showNegativeBtn: false,
        ));
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      ibUtils.showDialog(IbDialog(
        showNegativeBtn: false,
        title: 'OOPS!',
        subtitle: e.message ?? 'Something went wrong...',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      Get.back();
      ibUtils.showDialog(IbDialog(
        showNegativeBtn: false,
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
    } finally {
      isSigningUp.value = false;
    }
  }

  Future<void> navigateToCorrectPage() async {
    try {
      final statusSnap = await IbDbStatusService().queryStatus();
      final isOkay = await _handleDbStatus(statusSnap);

      final result = await Connectivity().checkConnectivity();
      if (result == ConnectivityResult.none) {
        ibUtils.showSimpleSnackBar(
            msg: 'No Internet Connection',
            backgroundColor: IbColors.errorRed,
            isPersistent: true);
      }

      if (firebaseUser != null && firebaseUser!.emailVerified) {
        final IbUser? ibUser =
            await IbUserDbService().queryIbUser(firebaseUser!.uid);
        if (!isOkay &&
            ibUser != null &&
            !ibUser.roles.contains(IbUser.kAdminRole)) {
          return;
        }

        /// check roles of the user
        if (ibUser != null &&
            ibUser.roles.contains(IbUser.kAdminRole) &&
            ibUser.roles.contains(IbUser.kUserRole)) {
          await IbAnalyticsManager().logScreenView(
              className: "AuthController", screenName: "RoleSelectPage");
          ibUtils.offAll(RoleSelectPage());
          return;
        } else if (ibUser != null && ibUser.roles.contains(IbUser.kAdminRole)) {
          await IbAnalyticsManager().logScreenView(
              className: "AuthController", screenName: "AdminMainPage");
          ibUtils.offAll(AdminMainPage());
        }

        String? status = '';
        if (ibUser == null) {
          status = null;
        } else {
          status = ibUser.status;
          if (ibUser.banedEndTimeInMs != -1 &&
              Timestamp.now().millisecondsSinceEpoch <
                  ibUser.banedEndTimeInMs) {
            status = IbUser.kUserStatusBanned;
          }
        }

        switch (status) {
          case IbUser.kUserStatusApproved:
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "MainPage");
            ibUtils.offAll(MainPage(),
                binding: HomeBinding(ibUser!),
                transition: Transition.circularReveal);
            break;

          case IbUser.kUserStatusBanned:
            print('Go to CounterDown Page');
            ibUtils.offAll(BannedCountDownPage(ibUser!),
                transition: Transition.circularReveal);
            break;

          case IbUser.kUserStatusPending:
            print('Go to InReview Page');
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "ReviewPage");
            ibUtils.offAll(ReviewPage(), transition: Transition.circularReveal);

            break;

          case IbUser.kUserStatusRejected:
            print('Go to Setup Page with note dialog');
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "SetupPageOne");
            Get.back();
            ibUtils.toPage(
                SetupPageOne(Get.put(
                    SetupController(status: IbUser.kUserStatusRejected),
                    tag: IbUtils().getUniqueId())),
                transition: Transition.circularReveal);
            break;

          case null:
            print('Go to Setup page');
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "SetupPageOne");
            Get.back();
            ibUtils.toPage(
                SetupPageOne(
                    Get.put(SetupController(), tag: IbUtils().getUniqueId())),
                transition: Transition.circularReveal);

            break;

          default:
            print('default Go to Setup page');
            await IbAnalyticsManager().logScreenView(
                className: "AuthController", screenName: "SetupPageOne");
            Get.back();
            ibUtils.toPage(
                SetupPageOne(
                    Get.put(SetupController(), tag: IbUtils().getUniqueId())),
                transition: Transition.circularReveal);
            break;
        }
      } else if (firebaseUser != null && !firebaseUser!.emailVerified) {
        ibUtils.showSimpleSnackBar(
            msg: 'User email is not verified yet',
            backgroundColor: IbColors.primaryColor);
        ibUtils.offAll(WelcomePage());
      }
    } on FirebaseAuthException catch (e) {
      ibUtils.showDialog(IbDialog(
        showNegativeBtn: false,
        title: 'OOPS!',
        subtitle: e.message ?? '',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      ibUtils.showDialog(IbDialog(
        showNegativeBtn: false,
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
    } finally {
      isInitializing.value = false;
    }
  }

  Future<void> resetPassword(String email) async {
    ibUtils.showDialog(const IbLoadingDialog(messageTrKey: 'loading'));
    try {
      await IbAnalyticsManager().logCustomEvent(name: "reset_pwd", data: {});
      await ibAuthService.resetPassword(email);
      Get.back();
      final String msg = 'reset_email_msg'.trParams({'email': email});
      ibUtils.showDialog(IbDialog(
        title: 'Reset Password',
        subtitle: msg,
        positiveTextKey: 'ok',
        showNegativeBtn: false,
      ));
    } on FirebaseAuthException catch (e) {
      Get.back();
      ibUtils.showDialog(IbDialog(
        showNegativeBtn: false,
        title: 'OOPS!',
        subtitle: e.message ?? 'Something went wrong...',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      Get.back();
      ibUtils.showDialog(IbDialog(
        showNegativeBtn: false,
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
    }
  }

  Future<void> signOut() async {
    ibUtils.showDialog(const IbLoadingDialog(messageTrKey: 'signing_out'));
    if (firebaseUser != null) {
      await IbUserDbService().removeTokenFromDatabase();
    }
    await ibAuthService.signOut();
  }
}
