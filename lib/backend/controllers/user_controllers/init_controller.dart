import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class InitController extends GetxService {
  final isLoading = true.obs;
  final hasError = false.obs;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      await GetStorage.init();
    } catch (e) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }
}
