import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/friend_item_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SocialTabController extends GetxController {
  final friends = <IbUser>[].obs;
  final RefreshController friendListRefreshController = RefreshController();
  late StreamSubscription ibUserSub;
  late StreamSubscription ibPublicAnswerSub;
  final isFriendListLoading = true.obs;
  @override
  Future<void> onInit() async {
    super.onInit();
    await initFriendList();
  }

  @override
  void onClose() {
    super.onClose();
    friendListRefreshController.dispose();
    ibPublicAnswerSub.cancel();
    ibUserSub.cancel();
  }

  Future<void> initFriendList() async {
    for (final String id in IbUtils.getCurrentIbUser()!.friendUids) {
      IbUser? user;
      if (IbCacheManager().getIbUser(id) == null) {
        user = await IbUserDbService().queryIbUser(id);
      } else {
        user = IbCacheManager().getIbUser(id);
      }

      if (user == null) {
        continue;
      }
      friends.add(user);
    }

    friends.sort((a, b) => a.username.compareTo(b.username));
    isFriendListLoading.value = false;

    ibUserSub = Get.find<MainPageController>()
        .ibUserBroadcastStream
        .listen((ibUser) async {
      friends.clear();
      for (final String id in ibUser.friendUids) {
        IbUser? user;
        if (IbCacheManager().getIbUser(id) == null) {
          user = await IbUserDbService().queryIbUser(id);
        } else {
          user = IbCacheManager().getIbUser(id);
        }

        if (user == null) {
          continue;
        }
        friends.add(user);
      }
      friends.sort((a, b) => a.username.compareTo(b.username));
      isFriendListLoading.value = false;
    });

    ibPublicAnswerSub = IbQuestionDbService()
        .listenToUserPublicAnsweredQuestionsChange(IbUtils.getCurrentUid()!)
        .listen((event) {
      for (final docChange in event.docChanges) {
        final IbAnswer ibAnswer = IbAnswer.fromJson(docChange.doc.data()!);
        if (docChange.type == DocumentChangeType.removed) {
          IbCacheManager().removeSingleIbAnswer(
              uid: IbUtils.getCurrentUid()!, ibAnswer: ibAnswer);
        } else {
          IbCacheManager().cacheSingleIbAnswer(
              uid: IbUtils.getCurrentUid()!, ibAnswer: ibAnswer);
        }
      }

      /// refresh friend list
      for (final user in friends) {
        if (Get.isRegistered<FriendItemController>(tag: user.username)) {
          Get.find<FriendItemController>(tag: user.username).refreshItem(false);
        }
      }
    });
  }

  Future<void> onFriendListRefresh() async {
    isFriendListLoading.value = true;
    friends.clear();

    /// refresh friend list
    for (final String id in IbUtils.getCurrentIbUser()!.friendUids) {
      IbUser? user;
      user = await IbUserDbService().queryIbUser(id);
      IbCacheManager().cacheIbUser(user);

      if (user == null) {
        continue;
      }
      friends.add(user);
    }

    for (final user in friends) {
      if (Get.isRegistered<FriendItemController>(tag: user.username)) {
        Get.find<FriendItemController>(tag: user.username).refreshItem(true);
      }
    }
    friendListRefreshController.refreshCompleted();
    isFriendListLoading.value = false;
  }
}
