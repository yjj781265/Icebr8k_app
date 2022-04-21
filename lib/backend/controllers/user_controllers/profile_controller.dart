import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final isFriend = false.obs;
  final isProfileVisible = false.obs;
  final isBlocked = false.obs;

  /// is friend request waiting for me for approval
  IbNotification? frNotification;

  /// is friend request sent
  IbNotification? frSentNotification;
  final isFrSent = false.obs;
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
      isFriend.value = user.friendUids.contains(IbUtils.getCurrentUid());
      frSentNotification =
          await IbUserDbService().querySentFriendRequest(user.id);
      isFrSent.value = frSentNotification != null;
      frNotification = await IbUserDbService()
          .isFriendRequestWaitingForMeForApproval(user.id);
      isBlocked.value =
          user.blockedFriendUids.contains(IbUtils.getCurrentUid());
      isProfileVisible.value = _handleProfileVisibility();
      isLoading.value = false;
    }

    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    scrollController.dispose();
    refreshController.dispose();
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
      isFriend.value = user.friendUids.contains(IbUtils.getCurrentUid());
      frSentNotification =
          await IbUserDbService().querySentFriendRequest(user.id);
      isFrSent.value = frSentNotification != null;
      frNotification = await IbUserDbService()
          .isFriendRequestWaitingForMeForApproval(user.id);
      isBlocked.value =
          user.blockedFriendUids.contains(IbUtils.getCurrentUid());
      isProfileVisible.value = _handleProfileVisibility();
      rxIbUser.refresh();
      refreshController.refreshCompleted();
    } else {
      refreshController.refreshFailed();
    }
  }

  bool _handleProfileVisibility() {
    if (isBlocked.isTrue ||
        rxIbUser.value.profilePrivacy == IbUser.kUserPrivacyPrivate) {
      return false;
    }

    if (isFriend.isTrue &&
        rxIbUser.value.profilePrivacy == IbUser.kUserPrivacyFrOnly) {
      return true;
    }

    if (rxIbUser.value.profilePrivacy == IbUser.kUserPrivacyPublic) {
      return true;
    }

    return false;
  }

  Future<void> addFriend(String message) async {
    final IbUser? currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null || isFrSent.isTrue) {
      return;
    }

    if (currentUser.friendUids.length >= IbConfig.kFriendsLimit) {
      IbUtils.showSimpleSnackBar(
          msg:
              'Failed to add friend, you have reach your ${IbConfig.kFriendsLimit} friends limit',
          backgroundColor: IbColors.errorRed);
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
      await IbUserDbService().sendAlertNotification(n);
      frSentNotification = n;
      isFrSent.value = frSentNotification != null;
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
      isProfileVisible.value = isFriend.isTrue &&
              rxIbUser.value.profilePrivacy == IbUser.kUserPrivacyFrOnly ||
          rxIbUser.value.profilePrivacy == IbUser.kUserPrivacyPublic;
      IbUtils.showSimpleSnackBar(
          msg: 'Friend deleted!', backgroundColor: IbColors.errorRed);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Delete friend failed $e', backgroundColor: IbColors.errorRed);
    }
  }
}
