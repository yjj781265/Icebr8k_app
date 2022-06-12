import 'dart:async';
import 'dart:io';

import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_api_keys_manager.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:purchases_flutter/models/purchaser_info_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// this controller control info of current IbUser, index current home page tab and api keys
class MainPageController extends GetxController {
  final currentIndex = 0.obs;
  final entitlement = 'premium';

  late StreamSubscription ibUserSub;
  final isNavBarVisible = true.obs;
  Rx<IbUser> rxCurrentIbUser;

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
    await _queryPurchaseInfo();
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    await ibUserSub.cancel();
  }

  Future<void> _queryPurchaseInfo() async {
    ///query purchase Info
    try {
      final String androidKey = IbApiKeysManager.kRevenueCatAndroidKey;
      final String iosKey = IbApiKeysManager.kRevenueCatIosKey;
      print(androidKey);
      if (Platform.isAndroid && androidKey.isNotEmpty) {
        await Purchases.setup(androidKey, appUserId: IbUtils.getCurrentUid());
      } else if (Platform.isIOS && iosKey.isNotEmpty) {
        await Purchases.setup(iosKey, appUserId: IbUtils.getCurrentUid());
      }
      if (Platform.isAndroid && androidKey.isNotEmpty) {
        await Purchases.setup(androidKey, appUserId: IbUtils.getCurrentUid());
      } else if (Platform.isIOS && iosKey.isNotEmpty) {
        await Purchases.setup(iosKey, appUserId: IbUtils.getCurrentUid());
      }
      final PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      await _handlePurchaseInfo(purchaserInfo);
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handlePurchaseInfo(PurchaserInfo purchaserInfo) async {
    bool isActive;
    try {
      if (purchaserInfo.entitlements.all[entitlement] == null) {
        isActive = false;
      } else {
        isActive = purchaserInfo.entitlements.all[entitlement]!.isActive;
      }
      await IbUserDbService().updateCurrentIbUserPremium(isActive);
    } catch (e) {
      print(e);
      await IbUserDbService().updateCurrentIbUserPremium(false);
    }
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
