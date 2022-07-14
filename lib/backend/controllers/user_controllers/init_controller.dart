import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
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
    isLoading.value = false;
  }

  @override
  Future<void> onReady() async {
    networkSub = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        IbUtils().showSimpleSnackBar(
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
}
