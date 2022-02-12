import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/main_page_controller.dart';

/// controller for Question tab in Homepage
class HomeTabController extends GetxController {
  final avatarUrl = ''.obs;

  late StreamSubscription ibUserSub;

  @override
  void onInit() {
    super.onInit();
    ibUserSub =
        Get.find<MainPageController>().ibUserBroadcastStream.listen((ibUser) {
      if (ibUser == null) {
        avatarUrl.value = '';
      }
      avatarUrl.value = ibUser!.avatarUrl;
    });
  }
}
