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
import 'package:url_launcher/url_launcher_string.dart';

class IbPremiumController extends GetxController {
  final List<String> _productIds = [
    'ib_weekly_premium',
    'ib_monthly_premium',
    'ib_yearly_premium'
  ];
  final entitlement = 'premium';
  final products = <Product>[].obs;
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
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'IbPremiumController', screenName: 'IbPremiumPage');
  }

  Future<void> _initPlatformState() async {
    isLoading.value = true;
    await Purchases.setDebugLogsEnabled(kDebugMode);
    try {
      if (!await Purchases.isConfigured) {
        await IbApiKeysManager().init();
        if (GetPlatform.isAndroid) {
          await Purchases.setup(IbApiKeysManager.kRevenueCatAndroidKey,
              appUserId: IbUtils().getCurrentUid());
        } else if (GetPlatform.isIOS) {
          await Purchases.setup(IbApiKeysManager.kRevenueCatIosKey,
              appUserId: IbUtils().getCurrentUid());
        }
      }

      /// load products
      products.value = await Purchases.getProducts(_productIds);
      products.sort((a, b) => a.price.compareTo(b.price));

      ///query purchase Info
      final PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();

      await _handlePurchaseInfo(purchaserInfo);

      ///listen to  purchase Info changes
      Purchases.addPurchaserInfoUpdateListener((info) {
        _handlePurchaseInfo(info);
      });
    } on PlatformException catch (e) {
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      await IbAnalyticsManager().logCustomEvent(
          name: 'error_load_products', data: {'errorCode': errorCode});
    } catch (e) {
      await IbAnalyticsManager()
          .logCustomEvent(name: 'error_load_products', data: {'error': e});
      print(e);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    print('IbPremiumController onClose');
    Purchases.removePurchaserInfoUpdateListener((purchaserInfo) {
      print('IbPremiumController onClose $purchaserInfo');
    });
  }

  Future<void> sync() async {
    try {
      await Purchases.syncPurchases();
    } catch (e) {
      print(e);
    }
  }

  Future<void> manageSubscription() async {
    ///query purchase Info
    final PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    if (await canLaunchUrlString(purchaserInfo.managementURL ?? '')) {
      launchUrlString(purchaserInfo.managementURL!);
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
    await sync();
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
      await IbAnalyticsManager().logCustomEvent(
          name: 'purchase_premium_error', data: {'error_code': errorCode});
      Get.dialog(IbDialog(
        title: 'Info',
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
