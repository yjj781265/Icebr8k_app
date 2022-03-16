import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final isFriend = false.obs;
  final isProfileVisible = false.obs;

  /// is friend request sent
  final isFrSent = false.obs;

  /// is friend request waiting for me for approval
  IbNotification? frNotification;
  final String uid;
  final compScore = 0.0.obs;
  late Rx<IbUser> rxIbUser;
  final double kAppBarCollapseHeight = 56;
  final RefreshController refreshController = RefreshController();
  final ScrollController scrollController = ScrollController();
  final commonAnswers = <String>[].obs;
  final uncommonAnswers = <String>[].obs;
  ProfileController(this.uid);

  @override
  Future<void> onInit() async {
    isLoading.value = true;
    final IbUser? user = await IbUserDbService().queryIbUser(uid);
    if (user != null) {
      rxIbUser = user.obs;
      commonAnswers.value = await IbUtils.getCommonAnswerQuestionIds(uid: uid);
      uncommonAnswers.value =
          await IbUtils.getUncommonAnswerQuestionIds(uid: uid);
      compScore.value = await IbUtils.getCompScore(uid: uid);
      isFriend.value = await IbUserDbService()
              .queryFriendshipStatus(IbUtils.getCurrentUid()!, user.id) ==
          IbFriend.kFriendshipStatusAccepted;
      isFrSent.value = await IbUserDbService().isFriendRequestSent(user.id);
      frNotification = await IbUserDbService()
          .isFriendRequestWaitingForMeForApproval(user.id);
      isProfileVisible.value =
          isFriend.isTrue && rxIbUser.value.isFriendsOnly ||
              !rxIbUser.value.isPrivate && !rxIbUser.value.isFriendsOnly;
      isLoading.value = false;
    }

    super.onInit();
  }

  Future<void> onRefresh() async {
    final IbUser? user = await IbUserDbService().queryIbUser(uid);
    if (user != null) {
      rxIbUser.value = user;
      commonAnswers.value =
          await IbUtils.getCommonAnswerQuestionIds(uid: uid, isRefresh: true);
      uncommonAnswers.value =
          await IbUtils.getUncommonAnswerQuestionIds(uid: uid, isRefresh: true);
      compScore.value = await IbUtils.getCompScore(uid: uid, isRefresh: true);
      isFriend.value = await IbUserDbService()
              .queryFriendshipStatus(IbUtils.getCurrentUid()!, user.id) ==
          IbFriend.kFriendshipStatusAccepted;
      isFrSent.value = await IbUserDbService().isFriendRequestSent(user.id);
      frNotification = await IbUserDbService()
          .isFriendRequestWaitingForMeForApproval(user.id);
      isProfileVisible.value =
          isFriend.isTrue && rxIbUser.value.isFriendsOnly ||
              !rxIbUser.value.isPrivate && !rxIbUser.value.isFriendsOnly;
      rxIbUser.refresh();
      refreshController.refreshCompleted();
    } else {
      refreshController.refreshFailed();
    }
  }

  Future<void> addFriend(String message) async {
    final IbUser? currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null || isFrSent.isTrue) {
      return;
    }

    final IbNotification n = IbNotification(
        id: IbUtils.getUniqueId(),
        title: currentUser.username,
        avatarUrl: currentUser.avatarUrl,
        subtitle: message,
        type: IbNotification.kFriendRequest,
        timestampInMs: DateTime.now().millisecondsSinceEpoch,
        senderId: currentUser.id,
        recipientId: rxIbUser.value.id);
    try {
      await IbUserDbService().sendFriendRequest(n);
      isFrSent.value = true;
      IbUtils.showSimpleSnackBar(
          msg: 'Friend request sent!', backgroundColor: IbColors.accentColor);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Friend request failed $e', backgroundColor: IbColors.errorRed);
    }
  }

  Future<void> removeFriend() async {
    final IbUser? currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null) {
      return;
    }
    try {
      await IbUserDbService().removeFriend(uid);
      isFriend.value = false;
      isProfileVisible.value =
          isFriend.isTrue && rxIbUser.value.isFriendsOnly ||
              !rxIbUser.value.isPrivate && !rxIbUser.value.isFriendsOnly;
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Delete friend failed $e', backgroundColor: IbColors.errorRed);
    }
  }
}
