import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final String uid;
  final compScore = 0.0.obs;
  final titlePadding = 8.0.obs;
  late Rx<IbUser> rxIbUser;
  StreamSubscription? friendStatusStream;
  final double kAppBarCollapseHeight = 56;
  final isCollapsing = false.obs;
  final RefreshController refreshController = RefreshController();
  final ScrollController scrollController = ScrollController();
  final commonAnswers = <IbAnswer>[].obs;
  final uncommonAnswers = <IbAnswer>[].obs;
  ProfileController(this.uid);

  @override
  Future<void> onInit() async {
    isLoading.value = true;
    final IbUser? user = await IbUserDbService().queryIbUser(uid);
    if (user != null) {
      rxIbUser = user.obs;
      commonAnswers.value = await IbUtils.getCommonAnswersQ(uid: uid);
      uncommonAnswers.value = await IbUtils.getUncommonAnswersQ(uid: uid);
      compScore.value = await IbUtils.getCompScore(uid: uid);
    }

    scrollController.addListener(() {
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

    isLoading.value = false;

    super.onInit();
  }

  Future<void> onRefresh() async {
    final IbUser? user = await IbUserDbService().queryIbUser(uid);
    if (user != null) {
      rxIbUser = user.obs;
      rxIbUser = user.obs;
      commonAnswers.value =
          await IbUtils.getCommonAnswersQ(uid: uid, isRefresh: true);
      uncommonAnswers.value =
          await IbUtils.getUncommonAnswersQ(uid: uid, isRefresh: true);
      compScore.value = await IbUtils.getCompScore(uid: uid, isRefresh: true);
    }
    refreshController.refreshCompleted();
  }

  @override
  void onClose() {
    if (friendStatusStream != null) {
      friendStatusStream!.cancel();
    }

    super.onClose();
  }
}
