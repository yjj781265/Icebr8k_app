import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import 'main_page_controller.dart';

class MyProfileController extends GetxController {
  late StreamSubscription ibUserSub;
  final Rx<IbUser> rxIbUser = IbUtils.getCurrentIbUser()!.obs;
  final RxList<IbEmoPic> rxEmoPics = <IbEmoPic>[].obs;
  final ScrollController scrollController = ScrollController();
  final double kAppBarCollapseHeight = 56;
  final titlePadding = 8.0.obs;
  final isCollapsing = false.obs;

  MyProfileController() {
    rxEmoPics.value = rxIbUser.value.emoPics;
  }

  @override
  void onInit() {
    super.onInit();
    ibUserSub =
        Get.find<MainPageController>().ibUserBroadcastStream.listen((ibUser) {
      rxIbUser.value = ibUser;
      rxIbUser.refresh();
    });
    scrollController.addListener(() {
      print(scrollController);
      titlePadding.value =
          ((scrollController.offset / 206) * kAppBarCollapseHeight) >
                  kAppBarCollapseHeight
              ? kAppBarCollapseHeight
              : (scrollController.offset / 206) * kAppBarCollapseHeight;
      if (scrollController.offset > kAppBarCollapseHeight) {
        isCollapsing.value = true;
      } else {
        isCollapsing.value = false;
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    ibUserSub.cancel();
  }
}
