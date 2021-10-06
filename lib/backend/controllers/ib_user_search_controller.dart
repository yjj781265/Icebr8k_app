import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_cloud_messaging_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbUserSearchController extends GetxController {
  final searchTxt = ''.obs;
  final friendUid = ''.obs;
  final username = ''.obs;
  final avatarUrl = ''.obs;
  final friendshipStatus = ''.obs;
  final score = (-1.0).obs;
  final isSearching = false.obs;
  final noResultTrKey = ''.obs;
  IbUser? ibUser;
  String requestMsg = '';

  @override
  void onInit() {
    super.onInit();
    debounce(searchTxt, (_) => _searchIbUsername(),
        time:
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
  }

  void _searchIbUsername() {
    _reset();
    isSearching.value = true;
    IbUserDbService()
        .queryIbUserFromUsername(searchTxt.value)
        .then((user) async {
      if (user == null) {
        _reset();
        noResultTrKey.value = 'user_not_found';
        return;
      }
      ibUser = user;
      noResultTrKey.value = '';
      username.value = user.username;
      avatarUrl.value = user.avatarUrl;
      friendUid.value = user.id;
      final String? status = await IbUserDbService().queryFriendshipStatus(
          Get.find<AuthController>().firebaseUser!.uid, user.id);
      friendshipStatus.value = status ?? '';
      score.value = await IbUtils.getCompScore(friendUid.value);
      isSearching.value = false;
    });
  }

  void _reset() {
    username.value = '';
    avatarUrl.value = '';
    score.value = -1.0;
    friendUid.value = '';
    isSearching.value = false;
    noResultTrKey.value = '';
    friendshipStatus.value = '';
    requestMsg = '';
  }

  Future<void> sendFriendRequest() async {
    try {
      await IbUserDbService().sendFriendRequest(
          myUid: Get.find<AuthController>().firebaseUser!.uid,
          friendUid: friendUid.value,
          requestMsg: requestMsg);
      final _token =
          await IbCloudMessagingService().retrieveToken(friendUid.value);

      if (_token != null) {
        await IbCloudMessagingService().sendNotification(
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
}
