import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class FriendRequestController extends GetxController {
  late StreamSubscription friendRequestStream;
  final requests = <FriendRequestItem>[].obs;
  GlobalKey<AnimatedListState> animatedListKey = GlobalKey<AnimatedListState>();

  @override
  void onInit() {
    initFriendRequestStream();
    super.onInit();
  }

  void initFriendRequestStream() {
    friendRequestStream = IbUserDbService()
        .listenToFriendRequest(Get.find<AuthController>().firebaseUser!.uid)
        .listen((event) async {
      print('find ${event.docChanges.length} requests');
      for (final change in event.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final IbFriend friend = IbFriend.fromJson(change.doc.data()!);
          final IbUser? user =
              await IbUserDbService().queryIbUser(friend.friendUid);
          final double score = await IbUtils.getCompScore(
              Get.find<AuthController>().firebaseUser!.uid, friend.friendUid);
          if (user != null) {
            final FriendRequestItem item = FriendRequestItem(
                avatarUrl: user.avatarUrl,
                username: user.username,
                timeStampInMs: friend.timestampInMs,
                friendUid: friend.friendUid,
                score: score,
                requestMsg: friend.requestMsg);
            requests.addIf(!requests.contains(item), item);
            if (animatedListKey.currentState == null) {
              continue;
            }
            animatedListKey.currentState!.insertItem(0);
          }
        }

        if (change.type == DocumentChangeType.modified) {
          print('modified ${change.doc['status'].toString()}');
        }

        if (change.type == DocumentChangeType.removed) {
          print('removed ${change.doc['status'].toString()}');
        }
      }
      requests.sort((a, b) => b.timeStampInMs.compareTo(a.timeStampInMs));
    });
  }

  void acceptFriendRequest(String friendUid) {
    IbUserDbService()
        .acceptFriendRequest(
            myUid: Get.find<AuthController>().firebaseUser!.uid,
            friendUid: friendUid)
        .then((value) {
      IbUtils.showSimpleSnackBar(
          msg: 'friend_request_accepted'.tr,
          backgroundColor: IbColors.accentColor);
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
