import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/managers/ib_api_keys_manager.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class IbPremiumController extends GetxController {
  final List<String> _productIds = [
    'ib_premium_monthly_old',
    'ib_premium_weekly_old',
    'ib_premium_yearly_old'
  ];
  final entitlement = 'premium';
  final offerings = <Offering>[].obs;
  final isPremium = false.obs;
  final isLoading = true.obs;
  final isRestoring = false.obs;
  EntitlementInfo? entitlementInfo;

  @override
  Future<void> onInit() async {
    await _initPlatformState();
    super.onInit();
  }

  @override
  Future<void> onClose() async {
    super.onClose();
  }

  Future<void> _initPlatformState() async {
    isLoading.value = true;
    await Purchases.setDebugLogsEnabled(kDebugMode);
    try {
      await IbApiKeysManager().init();
      if (GetPlatform.isAndroid) {
        await Purchases.setup(IbApiKeysManager.kRevenueCatAndroidKey,
            appUserId: IbUtils().getCurrentUid());
      } else if (GetPlatform.isIOS) {
        await Purchases.setup(IbApiKeysManager.kRevenueCatIosKey,
            appUserId: IbUtils().getCurrentUid());
      }
      if (await Purchases.isConfigured) {
        /// load products
        final offers = await Purchases.getOfferings();
        for (final id in _productIds) {
          final offer = offers.getOffering(id);
          if (offer != null) {
            offerings.add(offer);
          }
        }
        offerings.sort((a, b) => (a.availablePackages.first.product.price)
            .compareTo(b.availablePackages.first.product.price));
      } else {
        await IbAnalyticsManager().logCustomEvent(name: 'error_load_products');
        isLoading.value = false;
        return;
      }

      ///query purchase Info
      final PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
      await _handlePurchaseInfo(purchaserInfo);
      isLoading.value = false;

      ///listen to  purchase Info changes
      Purchases.addPurchaserInfoUpdateListener((info) {
        _handlePurchaseInfo(info);
      });
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      await IbAnalyticsManager().logCustomEvent(
          name: 'error_load_products', data: {'errorCode': errorCode});
      isLoading.value = false;
    }
  }

  Future<void> sync() async {
    try {
      await Purchases.syncPurchases();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _handlePurchaseInfo(PurchaserInfo purchaserInfo) async {
    if (purchaserInfo.entitlements.all[entitlement] == null) {
      entitlementInfo = null;
      isPremium.value = false;
    } else {
      entitlementInfo = purchaserInfo.entitlements.all[entitlement];
      isPremium.value = entitlementInfo!.isActive;
    }
    print('User has premium $isPremium');
    await Purchases.syncPurchases();
    await IbUserDbService().updateCurrentIbUserPremium(isPremium.value);
  }

  Future<void> purchasePremium(Product product) async {
    try {
      IbUtils().showSimpleSnackBar(
          msg: "Loading...", backgroundColor: IbColors.primaryColor);
      final PurchaserInfo info =
          await Purchases.purchaseProduct(product.identifier);
      await IbAnalyticsManager().logCustomEvent(
          name: 'purchase_premium', data: {'type': product.identifier});
      bool isActive;
      if (info.entitlements.all[entitlement] == null) {
        isActive = false;
      } else {
        isActive = info.entitlements.all[entitlement]!.isActive;
      }

      if (isActive) {
        await IbUserDbService().updateCurrentIbUserPremium(isActive);
        await Purchases.syncPurchases();
      }
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      Get.dialog(IbDialog(
        title: 'Error(${errorCode.name})',
        subtitle: e.message ?? 'Oops, something went wrong',
        showNegativeBtn: false,
      ));
    }
  }

  Future<void> restorePurchase() async {
    try {
      isRestoring.value = true;
      await sync();
      final PurchaserInfo restoredInfo = await Purchases.restoreTransactions();
      if (restoredInfo.activeSubscriptions.isEmpty) {
        IbUtils().showSimpleSnackBar(
            msg: 'No active subscriptions found',
            backgroundColor: IbColors.primaryColor);
        return;
      }
      await _handlePurchaseInfo(restoredInfo);
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      Get.dialog(IbDialog(
        title: 'Error(${errorCode.name})',
        subtitle: e.message ?? 'Oops, something went wrong',
        showNegativeBtn: false,
      ));
    } finally {
      isRestoring.value = false;
    }
  }
}
