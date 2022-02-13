import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/main_page_controller.dart';

/// controller for Question tab in Homepage
class HomeTabController extends GetxController {
  final avatarUrl = ''.obs;
  double _lastOffset = 0;
  final double hideShowNavBarSensitivity = 3;

  late StreamSubscription ibUserSub;
  ScrollController scrollController = ScrollController();

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

    scrollController.addListener(() {
      if (scrollController.offset > _lastOffset &&
          scrollController.offset - _lastOffset > hideShowNavBarSensitivity) {
        Get.find<MainPageController>().hideNavBar();
      } else if (scrollController.offset < _lastOffset &&
          _lastOffset - scrollController.offset > hideShowNavBarSensitivity) {
        Get.find<MainPageController>().showNavBar();
      }
      _lastOffset = scrollController.offset;
    });
  }
}
