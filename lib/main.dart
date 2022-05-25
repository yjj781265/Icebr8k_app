import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/main_page.dart';
import 'package:icebr8k/frontend/ib_themes.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'backend/controllers/user_controllers/init_controller.dart';
import 'backend/services/user_services/ib_local_data_service.dart';
import 'frontend/ib_config.dart';
import 'frontend/ib_pages/splash_page.dart';
import 'frontend/ib_strings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  /// prevent blinking for cached images
  PaintingBinding.instance.imageCache.maximumSizeBytes = 1000 << 20; //1GB
  IbUtils.changeStatusBarColor();
  debugRepaintRainbowEnabled = false;
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
  runApp(MainApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

class MainApp extends StatelessWidget {
  final InitController _controller = Get.put(InitController());
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.hasError.isTrue) {
        return _somethingWrong();
      }

      if (_controller.isLoading.isTrue) {
        return _loading();
      }

      return RefreshConfiguration(
        headerBuilder: () => const ClassicHeader(),
        child: GetMaterialApp(
          defaultTransition: Transition.cupertino,
          debugShowCheckedModeBanner: false,
          initialRoute: './',
          routes: {
            './': (context) => SplashPage(),
            './home': (context) => MainPage()
          },
          enableLog: false,
          translations: IbStrings(),
          locale: const Locale('en', 'US'),
          themeMode: ThemeMode.light,
          theme:
              IbLocalDataService().retrieveBoolValue(StorageKey.isDarkModeBool)
                  ? IbThemes(context).buildDarkTheme()
                  : IbThemes(context).buildLightTheme(),
        ),
      );
    });
  }

  Widget _loading() {
    return Container(
      color: IbLocalDataService().retrieveBoolValue(StorageKey.isDarkModeBool)
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
