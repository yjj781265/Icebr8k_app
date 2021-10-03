import 'package:firebase_core/firebase_core.dart';
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
