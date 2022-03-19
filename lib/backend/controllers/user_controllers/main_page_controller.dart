import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_api_keys_manager.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

/// this controller control info of current IbUser, index current home page tab and api keys
class MainPageController extends GetxController {
  final currentIndex = 0.obs;
  final Stream<IbUser> ibUserBroadcastStream = IbUserDbService()
      .listenToIbUserChanges(IbUtils.getCurrentFbUser()!.uid)
      .asBroadcastStream();
  final isNavBarVisible = true.obs;
  Rx<IbUser> rxCurrentIbUser;
  late String kGooglePlacesApiKey;

  MainPageController(this.rxCurrentIbUser);

  @override
  Future<void> onInit() async {
    super.onInit();
    ibUserBroadcastStream.listen((ibUser) {
      rxCurrentIbUser = ibUser.obs;
      rxCurrentIbUser.refresh();
    });

    await IbApiKeysManager.init();
    // todo add manager to handle this
    await setupInteractedMessage();
  }

  // It is assumed that all messages contain a data field with the key 'type'
  Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  void showNavBar() {
    if (isNavBarVisible.isTrue) {
      return;
    }
    isNavBarVisible.value = true;
  }

  void hideNavBar() {
    if (isNavBarVisible.isFalse) {
      return;
    }
    isNavBarVisible.value = false;
  }

  void _handleMessage(RemoteMessage message) {
    /*final data = message.data;
    final type = data['type'];
    if (IbCloudMessagingService.kNotificationTypeChat == type) {
      final String? chatRoomId = data['chatRoomId'] as String?;
      if (chatRoomId == null || chatRoomId.isEmpty) {
        return;
      }

      IbChatDbService().queryMemberUids(chatRoomId).then((value) {
        Get.to(() => ChatPage(Get.put(ChatPageController(value))));
      });
    }*/
  }
}
