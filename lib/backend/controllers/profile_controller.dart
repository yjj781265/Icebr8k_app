import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final currentIndex = 0.obs;
  final String uid;
  String requestMsg = '';
  final avatarUrl = ''.obs;
  final coverPhotoUrl = ''.obs;
  final username = ''.obs;
  final birthdateInMs = 0.obs;
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
    isMe.value = uid == IbUtils.getCurrentUid()!;
    if (isMe.isFalse) {
      final String? status = await IbUserDbService()
          .queryFriendshipStatus(IbUtils.getCurrentUid()!, uid);
      friendshipStatus.value = status ?? '';
      compScore.value = await IbUtils.getCompScore(uid);

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
      totalAnsweredStream = IbQuestionDbService()
          .listenToAnsweredQuestionsChange(uid)
          .listen((event) async {
        // TODO convert to cloud function for getting the total count, important!
        final List ids =
            await IbQuestionDbService().queryAnsweredQuestionIds(uid);
        totalAnswered.value = ids.length;
      });

      totalAskedStream = IbQuestionDbService()
          .listenToUserAskedQuestionsChange(uid)
          .listen((event) async {
        final snapshot =
            await IbQuestionDbService().queryAskedQuestions(uid: uid);
        totalAsked.value = snapshot.size;
      });
    }

    final IbUser? user = await IbUserDbService().queryIbUser(uid);
    if (user == null) {
      isLoading.value = false;
      return;
    }

    avatarUrl.value = user.avatarUrl;
    coverPhotoUrl.value = user.coverPhotoUrl;
    username.value = user.username;
    name.value = user.name;
    description.value = user.description;
    birthdateInMs.value = user.birthdateInMs;
    isLoading.value = false;
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

  Future<void> updateCoverPhoto(String _filePath) async {
    if (isMe.isFalse) {
      return;
    }

    Get.dialog(const IbLoadingDialog(messageTrKey: 'uploading...'),
        barrierDismissible: false);

    final String? photoUrl =
        await IbStorageService().uploadAndRetrieveImgUrl(_filePath);

    if (photoUrl == null) {
      Get.back();
      return;
    }

    await IbUserDbService()
        .updateCoverPhotoUrl(photoUrl: photoUrl, uid: IbUtils.getCurrentUid()!);
    Get.back();
  }
}
