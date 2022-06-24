import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/auth_controller.dart';

class IbAnalyticsManager {
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final IbAnalyticsManager _manager = IbAnalyticsManager._();

  factory IbAnalyticsManager() => _manager;

  IbAnalyticsManager._();

  Future<void> logCustomEvent(
      {required String name, Map<String, dynamic> data = const {}}) async {
    if (!Get.find<AuthController>().isAnalyticsEnabled || kDebugMode) {
      return;
    }
    await analytics.logEvent(
      name: name,
      parameters: data,
    );
  }

  Future<void> logScreenView({
    required String className,
    required String screenName,
  }) async {
    if (!Get.find<AuthController>().isAnalyticsEnabled || kDebugMode) {
      return;
    }
    await analytics.logScreenView(
        screenClass: className, screenName: screenName);
  }

  Future<void> logSignIn(String methodName) async {
    if (!Get.find<AuthController>().isAnalyticsEnabled || kDebugMode) {
      return;
    }
    await analytics.logLogin(loginMethod: methodName);
  }

  Future<void> logSignUp(String methodName) async {
    if (!Get.find<AuthController>().isAnalyticsEnabled || kDebugMode) {
      return;
    }
    await analytics.logSignUp(signUpMethod: methodName);
  }

  Future<void> logJoinGroup(String groupId) async {
    if (!Get.find<AuthController>().isAnalyticsEnabled || kDebugMode) {
      return;
    }

    await analytics.logJoinGroup(groupId: groupId);
  }

  Future<void> logSearch(String text) async {
    if (!Get.find<AuthController>().isAnalyticsEnabled || kDebugMode) {
      return;
    }
    await analytics.logSearch(searchTerm: text);
  }

  Future<void> logShare(
      {required String contentType,
      required String itemId,
      required String methodName}) async {
    if (!Get.find<AuthController>().isAnalyticsEnabled || kDebugMode) {
      return;
    }
    await analytics.logShare(
        contentType: contentType, itemId: itemId, method: methodName);
  }
}
