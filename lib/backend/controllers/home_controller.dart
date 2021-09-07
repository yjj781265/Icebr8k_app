import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
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
    ('social'.tr),
    '${'profile'.tr} 👤'
  ];

  @override
  void onInit() {
    super.onInit();
    if (IbUtils.getCurrentUid() == null) {
      print('HomeController unable retrieve current user UID');
    }
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

  @override
  void onClose() {
    _currentIbUserStream.cancel();
  }
}
