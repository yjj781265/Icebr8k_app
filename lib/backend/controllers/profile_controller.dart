import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class ProfileController extends GetxController {
  final currentIndex = 0.obs;
  final String uid;
  String requestMsg = '';
  final avatarUrl = ''.obs;
  final coverPhotoUrl = ''.obs;
  final username = ''.obs;
  final name = ''.obs;
  final description = ''.obs;
  final isMe = false.obs;
  final compScore = 0.0.obs;
  final totalAsked = 0.obs;
  final totalAnswered = 0.obs;
  final friendshipStatus = ''.obs;
  StreamSubscription? totalAskedStream;
  StreamSubscription? totalAnsweredStream;
  StreamSubscription? friendStatusStream;
  ProfileController(this.uid);

  @override
  Future<void> onInit() async {
    isMe.value = uid == IbUtils.getCurrentUid();
    if (isMe.isFalse) {
      final String? status = await IbUserDbService()
          .queryFriendshipStatus(IbUtils.getCurrentUid()!, uid);
      friendshipStatus.value = status ?? '';
      compScore.value =
          await IbUtils.getCompScore(IbUtils.getCurrentUid()!, uid);

      // TODO convert to cloud function for getting the total count, important!
      final List ids =
          await IbQuestionDbService().queryAnsweredQuestionIds(uid);
      totalAnswered.value = ids.length;

      final snapshot =
          await IbQuestionDbService().queryAskedQuestions(uid: uid);
      totalAsked.value = snapshot.size;

      friendStatusStream =
          IbUserDbService().listenToSingleFriend(uid).listen((event) {
        if (!event.exists) {
          friendshipStatus.value = '';
          return;
        }
        friendshipStatus.value = event['status'].toString();
      }, onError: (error) {
        friendshipStatus.value = '';
      });
    } else {
      totalAskedStream = IbQuestionDbService()
          .listenToAnsweredQuestionsChange(uid)
          .listen((event) async {
        // TODO convert to cloud function for getting the total count, important!
        final List ids =
            await IbQuestionDbService().queryAnsweredQuestionIds(uid);
        totalAnswered.value = ids.length;
      });

      totalAnsweredStream = IbQuestionDbService()
          .listenToUserAskedQuestionsChange(uid)
          .listen((event) async {
        final snapshot =
            await IbQuestionDbService().queryAskedQuestions(uid: uid);
        totalAsked.value = snapshot.size;
      });
    }

    final IbUser? user = await IbUserDbService().queryIbUser(uid);
    if (user == null) {
      return;
    }

    avatarUrl.value = user.avatarUrl;
    coverPhotoUrl.value = user.coverPhotoUrl;
    username.value = user.username;
    name.value = user.name;
    description.value = user.description;
    super.onInit();
  }

  @override
  void onClose() {
    if (totalAskedStream != null) {
      totalAskedStream!.cancel();
    }

    if (totalAnsweredStream != null) {
      totalAnsweredStream!.cancel();
    }

    if (friendStatusStream != null) {
      friendStatusStream!.cancel();
    }

    super.onClose();
  }

  Future<void> sendFriendRequest() async {
    try {
      await IbUserDbService().sendFriendRequest(
          myUid: IbUtils.getCurrentUid()!,
          friendUid: uid,
          requestMsg: requestMsg);
      friendshipStatus.value = IbFriend.kFriendshipStatusRequestSent;
      Get.showSnackbar(GetBar(
        borderRadius: IbConfig.kCardCornerRadius,
        margin: const EdgeInsets.all(8),
        duration: const Duration(seconds: 3),
        backgroundColor: IbColors.accentColor,
        messageText: Text('send_friend_request_success'.tr),
      ));
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  void unfriend() {
    print('ProfileController unfriend');
    IbUserDbService()
        .rejectFriendRequest(myUid: IbUtils.getCurrentUid()!, friendUid: uid)
        .then((value) {
      friendshipStatus.value = '';
    }).onError((error, stackTrace) {
      IbUtils.showSimpleSnackBar(
          msg: error.toString(), backgroundColor: IbColors.errorRed);
    });
  }
}