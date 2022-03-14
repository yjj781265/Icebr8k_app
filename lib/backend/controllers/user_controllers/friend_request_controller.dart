import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../services/user_services/ib_cloud_messaging_service.dart';
import '../../services/user_services/ib_user_db_service.dart';
import 'auth_controller.dart';

/// controller for current user's friend request list in Social tab in Home Page
class FriendRequestController extends GetxController {
  late StreamSubscription friendRequestStream;
  final requests = <FriendRequestItem>[].obs;
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();

  @override
  void onInit() {
    super.onInit();
  }

  void acceptFriendRequest(String friendUid) {
    IbUserDbService()
        .acceptFriendRequest(
            myUid: Get.find<AuthController>().firebaseUser!.uid,
            friendUid: friendUid)
        .then((value) async {
      IbUtils.showSimpleSnackBar(
          msg: 'friend_request_accepted'.tr,
          backgroundColor: IbColors.accentColor);
      final token = await IbCloudMessagingService().retrieveToken(friendUid);
      if (token != null && IbUtils.getCurrentIbUser() != null) {
        await IbCloudMessagingService().sendNotification(
            tokens: [token],
            title: IbUtils.getCurrentIbUser()!.username,
            body: "has accepted your friend request",
            type: IbCloudMessagingService.kNotificationTypeDefault);
      }
    }).onError((error, stackTrace) {
      IbUtils.showSimpleSnackBar(
          msg: error.toString(), backgroundColor: IbColors.errorRed);
    });
  }

  void rejectFriendRequest(String friendUid) {
    IbUserDbService()
        .rejectFriendRequest(
            myUid: Get.find<AuthController>().firebaseUser!.uid,
            friendUid: friendUid)
        .then((value) {
      IbUtils.showSimpleSnackBar(
          msg: 'friend_request_declined'.tr,
          backgroundColor: IbColors.errorRed);
    }).onError((error, stackTrace) {
      IbUtils.showSimpleSnackBar(
          msg: error.toString(), backgroundColor: IbColors.errorRed);
    });
  }

  @override
  void onClose() {
    friendRequestStream.cancel();
    super.onClose();
  }
}

class FriendRequestItem {
  String requestMsg = '';
  String avatarUrl = '';
  String username = '';
  int timeStampInMs = 0;
  double score = 0;
  String friendUid;

  FriendRequestItem(
      {required this.requestMsg,
      required this.avatarUrl,
      required this.username,
      required this.friendUid,
      required this.score,
      required this.timeStampInMs});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendRequestItem &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          friendUid == other.friendUid;

  @override
  int get hashCode => username.hashCode ^ friendUid.hashCode;
}
