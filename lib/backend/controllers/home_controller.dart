import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final isIbUserOnline = false.obs;
  final currentIbName = ''.obs;
  final currentIbUsername = ''.obs;
  final currentIbAvatarUrl = ''.obs;
  final currentIbCoverPhotoUrl = ''.obs;
  IbUser? currentIbUser;
  late StreamSubscription _currentIbUserStream;
  final tabTitleList = [
    '${'question'.tr} 🤔',
    '${'chat'.tr} 💬',
    '${'score'.tr} 💯',
    '${'profile'.tr} 👤'
  ];

  @override
  void onInit() {
    super.onInit();
    _currentIbUserStream = IbUserDbService()
        .listenToIbUserChanges(Get.find<AuthController>().firebaseUser!.uid)
        .listen((ibUser) {
      currentIbUser = ibUser;
      _setupIbUser();
    });
  }

  void _setupIbUser() {
    if (currentIbUser != null) {
      isIbUserOnline.value = currentIbUser!.isOnline;
      currentIbName.value = currentIbUser!.name;
      currentIbUsername.value = currentIbUser!.username;
      currentIbAvatarUrl.value = currentIbUser!.avatarUrl;
      currentIbCoverPhotoUrl.value = currentIbUser!.coverPhotoUrl;
    }
  }

  @override
  void onClose() {
    _currentIbUserStream.cancel();
  }
}
