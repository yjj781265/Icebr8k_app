import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/main_page_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';

/// controller for Question tab in Homepage
class HomeTabController extends GetxController {
  final avatarUrl = ''.obs;
  double _lastOffset = 0;
  final double hideShowNavBarSensitivity = 10;
  final currentList = <IbQuestion>[].obs;

  late StreamSubscription ibUserSub;
  ScrollController scrollController = ScrollController();

  @override
  Future<void> onInit() async {
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

    currentList.value = await IbQuestionDbService().queryIbQuestions(8);
  }
}
