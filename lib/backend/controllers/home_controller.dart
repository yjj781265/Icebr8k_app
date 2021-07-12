import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';

class HomeController extends GetxController {
  final currentIndex = 0.obs;
  final currentTabTitle = ''.obs;
  final isIbUserOnline = false.obs;
  final currentIbName = ''.obs;
  final currentIbUsername = ''.obs;
  final currentIbAvatarUrl = ''.obs;
  IbUser? currentIbUser;
  late StreamSubscription _currentIbUserStream;

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
      print(currentIbUser);
      isIbUserOnline.value = currentIbUser!.isOnline;
      currentIbName.value = currentIbUser!.name;
      currentIbUsername.value = currentIbUser!.username;
      currentIbAvatarUrl.value = currentIbUser!.avatarUrl;
    }
  }

  @override
  void onClose() {
    print('HomeController closed');
    super.onClose();
    _currentIbUserStream.cancel();
  }
}
