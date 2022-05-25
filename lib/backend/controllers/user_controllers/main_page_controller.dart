import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_api_keys_manager.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';

/// this controller control info of current IbUser, index current home page tab and api keys
class MainPageController extends GetxController {
  final currentIndex = 0.obs;

  late StreamSubscription ibUserSub;
  final isNavBarVisible = true.obs;
  Rx<IbUser> rxCurrentIbUser;
  late String kGooglePlacesApiKey;

  MainPageController(this.rxCurrentIbUser);

  @override
  Future<void> onInit() async {
    super.onInit();
    ibUserSub = IbUserDbService()
        .listenToIbUserChanges(rxCurrentIbUser.value.id)
        .listen((event) {
      rxCurrentIbUser.value = event;
      rxCurrentIbUser.refresh();
    });

    await IbApiKeysManager().init();
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    await ibUserSub.cancel();
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
}
