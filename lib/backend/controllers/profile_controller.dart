import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_cloud_messaging_service.dart';
import 'package:icebr8k/backend/services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileController extends GetxController {
  final isLoading = true.obs;
  final currentIndex = 0.obs;
  final String uid;
  final refreshController = RefreshController();
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

      totalAnswered.value =
          await IbUserDbService().queryIbUserAnsweredSize(uid);

      totalAsked.value = await IbUserDbService().queryIbUserAskedSize(uid);

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
      final _token = await IbCloudMessagingService().retrieveToken(uid);

      if (_token != null) {
        IbCloudMessagingService().sendNotification(
            tokens: [_token],
            title: IbUtils.getCurrentIbUser()!.username,
            body: '${'send_you_a_friend_request'.tr}\n $requestMsg',
            type: IbCloudMessagingService.kNotificationTypeRequest);
      }

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

    //delete the old one first
    if (IbUtils.getCurrentIbUser() != null &&
        IbUtils.getCurrentIbUser()!.coverPhotoUrl.isNotEmpty) {
      await IbStorageService()
          .deleteFile(IbUtils.getCurrentIbUser()!.coverPhotoUrl);
    }

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
