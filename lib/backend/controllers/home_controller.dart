import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/ib_cloud_messaging_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

/// this controller control info of current IbUser, and index current home page tab
class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final isIbUserOnline = false.obs;
  final currentIbName = ''.obs;
  final currentBio = ''.obs;
  final currentIbUsername = ''.obs;
  final currentIbAvatarUrl = ''.obs;
  final currentIbCoverPhotoUrl = ''.obs;
  final currentBirthdate = 0.obs;
  IbUser? currentIbUser;
  late StreamSubscription _currentIbUserStream;
  final tabTitleList = [
    '${'question'.tr} 🤔',
    '${'chat'.tr} 💬',
    '${'social'.tr} 🤝',
    '${'profile'.tr} 👤'
  ];

  @override
  Future<void> onInit() async {
    super.onInit();
    if (IbUtils.getCurrentUid() == null) {
      print('HomeController unable retrieve current user UID');
      return;
    }
    await setupInteractedMessage();
    _currentIbUserStream = IbUserDbService()
        .listenToIbUserChanges(IbUtils.getCurrentUid()!)
        .listen((ibUser) {
      currentIbUser = ibUser;
      _populateUserInfo();
    });
  }

  void _populateUserInfo() {
    if (currentIbUser != null) {
      isIbUserOnline.value = currentIbUser!.isOnline;
      currentIbName.value = currentIbUser!.name;
      currentIbUsername.value = currentIbUser!.username;
      currentIbAvatarUrl.value = currentIbUser!.avatarUrl;
      currentIbCoverPhotoUrl.value = currentIbUser!.coverPhotoUrl;
      currentBio.value = currentIbUser!.description;
      currentBirthdate.value = currentIbUser!.birthdateInMs;
    }
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

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];
    if (IbCloudMessagingService.kNotificationTypeChat == type) {
      final String? chatRoomId = data['chatRoomId'] as String?;
      if (chatRoomId == null || chatRoomId.isEmpty) {
        return;
      }

      IbChatDbService().queryMemberUids(chatRoomId).then((value) {
        Get.to(() => ChatPage(Get.put(ChatPageController(value))));
      });
    }

    if (IbCloudMessagingService.kNotificationTypeRequest == type) {
      currentIndex.value = 2;
      Get.find<SocialTabController>().tabController!.animateTo(2);
      return;
    }
  }

  @override
  void onClose() {
    _currentIbUserStream.cancel();
  }
}
