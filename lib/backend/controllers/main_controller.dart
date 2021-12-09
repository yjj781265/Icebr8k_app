import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';

class MainController extends GetxController {
  final isLoading = true.obs;
  final hasError = false.obs;

  @override
  Future<void> onInit() async {
    isLoading.value = true;
    print('init....');
    try {
      await GetStorage.init();
      await Firebase.initializeApp();

      //SetUp Crashlytics
      if (kDebugMode) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(false);
      } else {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(true);
      }

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
      // Pass all uncaught errors to Crashlytics.
      final void Function(FlutterErrorDetails)? originalOnError =
          FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails errorDetails) async {
        await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
        // Forward to original handler.
        if (originalOnError != null) {
          originalOnError(errorDetails);
        }
      };

      // remove all notifications while opening the app
      await FlutterLocalNotificationsPlugin().cancelAll();
      Get.put(AuthController());
    } on Exception catch (e) {
      print('MainController $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }

    super.onInit();
  }
}
