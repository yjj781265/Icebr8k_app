import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class InitController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    await GetStorage.init();
    await initCrashlytics();
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
