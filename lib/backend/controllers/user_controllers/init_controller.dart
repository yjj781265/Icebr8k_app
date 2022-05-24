import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class InitController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;
  late StreamSubscription networkSub;

  @override
  Future<void> onInit() async {
    super.onInit();

    await GetStorage.init();
    await initCrashlytics();
  }

  @override
  Future<void> onReady() async {
    networkSub = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        IbUtils.showSimpleSnackBar(
            msg: 'No Internet Connection',
            backgroundColor: IbColors.errorRed,
            isPersistent: true);
      } else if (result != ConnectivityResult.bluetooth) {
        Get.closeAllSnackbars();
      }
    });
    super.onReady();
  }

  @override
  Future<void> onClose() async {
    await networkSub.cancel();
  }

  Future<void> initCrashlytics() async {
    // If you're going to use other Firebase services in the background, such as Firestore,
    // make sure you call `initializeApp` before using other Firebase services.

    isLoading.value = true;
    print('InitController init....');
    try {
      //Todo replace with a manager
      //SetUp Crashlytics
      if (kDebugMode) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(false);
      } else {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      }
    } catch (e) {
      print('MainController $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
