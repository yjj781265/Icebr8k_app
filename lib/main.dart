import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/main_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_themes.dart';
import 'package:lottie/lottie.dart';

import 'backend/services/ib_local_storage_service.dart';
import 'frontend/ib_config.dart';
import 'frontend/ib_pages/splash_page.dart';
import 'frontend/ib_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  /// prevent blinking for cached images
  PaintingBinding.instance!.imageCache?.maximumSizeBytes = 1000 << 20; //1GB
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
        statusBarColor: !IbLocalStorageService()
                .isCustomKeyTrue(IbLocalStorageService.isLightModeCustomKey)
            ? Colors.black
            : IbColors.lightBlue),
  );
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MainApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print("Handling a background message: ${message.data}");
}

class MainApp extends StatelessWidget {
  final MainController _controller = Get.put(MainController());
  final FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.hasError.isTrue) {
        return _somethingWrong();
      }

      if (_controller.isLoading.isTrue) {
        return _loading();
      }

      return GetMaterialApp(
        navigatorObservers: [
          FirebaseAnalyticsObserver(analytics: analytics),
        ],
        defaultTransition: Transition.cupertino,
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
        enableLog: false,
        translations: IbStrings(),
        locale: const Locale('en', 'US'),
        themeMode: ThemeMode.light,
        theme: IbLocalStorageService()
                .isCustomKeyTrue(IbLocalStorageService.isLightModeCustomKey)
            ? IbThemes(context).buildLightTheme()
            : IbThemes(context).buildDarkTheme(),
      );
    });
  }

  Widget _loading() {
    return Container(
      color: !IbLocalStorageService()
              .isCustomKeyTrue(IbLocalStorageService.isLightModeCustomKey)
          ? Colors.black
          : IbColors.lightBlue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/logo_android.png',
              width: IbConfig.kAppLogoSize,
              height: IbConfig.kAppLogoSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _somethingWrong() {
    return Container(
      color: IbColors.lightBlue,
      child: Center(
        child: Lottie.asset('assets/images/error.json'),
      ),
    );
  }
}
