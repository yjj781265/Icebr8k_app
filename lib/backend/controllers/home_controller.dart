import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/answered_question_controller.dart';
import 'package:icebr8k/backend/controllers/asked_questions_controller.dart';
import 'package:icebr8k/backend/controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/ib_cloud_messaging_service.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_pages/chat_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

/// this controller control info of current IbUser, and index current home page tab
class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final isIbUserOnline = false.obs;
  final currentIbName = ''.obs;
  final currentBio = ''.obs;
  final askedSize = 0.obs;
  final answeredSize = 0.obs;
  final currentIbUsername = ''.obs;
  final currentIbAvatarUrl = ''.obs;
  final currentIbCoverPhotoUrl = ''.obs;
  final currentBirthdate = 0.obs;
  late BuildContext context;
  IbUser? currentIbUser;
  late StreamSubscription _currentIbUserStream;
  final tabTitleList = [
    '${'question'.tr} 🤔',
    '${'chat'.tr} 💬',
    '${'social'.tr} 🤝',
    '${'profile'.tr} 👤'
  ];

  final key1 = GlobalKey();
  final key2 = GlobalKey();
  final key3 = GlobalKey();

  @override
  Future<void> onInit() async {
    super.onInit();
    if (IbUtils.getCurrentUid() == null) {
      print('HomeController unable retrieve current user UID');
      return;
    }
    _currentIbUserStream = IbUserDbService()
        .listenToIbUserChanges(IbUtils.getCurrentUid()!)
        .listen((ibUser) {
      currentIbUser = ibUser;
      _populateUserInfo();
    });
    await IbCloudMessagingService().init();
    await setupInteractedMessage();
  }

  Future<void> _populateUserInfo() async {
    if (currentIbUser != null) {
      isIbUserOnline.value = currentIbUser!.isOnline;
      currentIbUsername.value = currentIbUser!.username;
      currentIbAvatarUrl.value = currentIbUser!.avatarUrl;
      currentIbCoverPhotoUrl.value = currentIbUser!.coverPhotoUrl;
      currentBio.value = currentIbUser!.bio;
      currentBirthdate.value = currentIbUser!.birthdateInMs!;
      // ignore: unnecessary_null_comparison
      if (currentIbUser!.askedSize == 0) {
        askedSize.value = (await IbQuestionDbService()
                .queryAskedQuestions(uid: currentIbUser!.id))
            .size;
      } else {
        askedSize.value = currentIbUser!.askedSize;
      }

      if (currentIbUser!.answeredSize == 0) {
        answeredSize.value = (await IbQuestionDbService()
                .queryAnsweredQuestionIds(currentIbUser!.id))
            .length;
      } else {
        answeredSize.value = currentIbUser!.answeredSize;
      }
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

  Future<void> handleIndex(int index) async {
    //refresh profile page tabs questions stats
    if (index == tabTitleList.length - 1) {
      if (Get.isRegistered<AnsweredQuestionController>(
          tag: IbUtils.getCurrentUid())) {
        await Get.find<AnsweredQuestionController>(tag: IbUtils.getCurrentUid())
            .updateItems();
      }

      if (Get.isRegistered<AskedQuestionsController>(
          tag: IbUtils.getCurrentUid())) {
        await Get.find<AskedQuestionsController>(tag: IbUtils.getCurrentUid())
            .updateItems();
      }
    }
  }

  @override
  void onClose() {
    _currentIbUserStream.cancel();
  }
}
