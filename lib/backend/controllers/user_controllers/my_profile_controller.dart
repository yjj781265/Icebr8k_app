import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/models/ib_user.dart';

import 'main_page_controller.dart';

class MyProfileController extends GetxController {
  late StreamSubscription ibUserSub;
  final Rx<IbUser> rxIbUser = Get.find<MainPageController>().rxCurrentIbUser;
  final RxList<IbEmoPic> rxEmoPics = <IbEmoPic>[].obs;
  final ScrollController scrollController = ScrollController();
  final double kAppBarCollapseHeight = 56;
  final titlePadding = 8.0.obs;
  final isCollapsing = false.obs;

  MyProfileController();

  @override
  void onInit() {
    super.onInit();
    rxEmoPics.value = rxIbUser.value.emoPics;
  }

  @override
  void onClose() {
    super.onClose();
    ibUserSub.cancel();
  }
}
