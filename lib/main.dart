import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/main_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:lottie/lottie.dart';

import 'frontend/ib_config.dart';
import 'frontend/ib_pages/splash_page.dart';
import 'frontend/ib_strings.dart';
import 'frontend/ib_themes.dart';
import 'frontend/ib_widgets/ib_progress_indicator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: IbColors.lightBlue),
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(MainApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.notification}");
}

class MainApp extends StatelessWidget {
  final MainController _controller = Get.put(MainController());

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
        defaultTransition: Transition.cupertino,
        enableLog: true,
        debugShowCheckedModeBanner: false,
        home: SplashPage(),
        translations: IbStrings(),
        locale: const Locale('en', 'US'),
        theme: IbThemes.lightTheme,
      );
    });
  }

  Widget _loading() {
    return Container(
      color: IbColors.lightBlue,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/logo_android.png',
              width: IbConfig.kAppLogoSize,
              height: IbConfig.kAppLogoSize,
            ),
            const IbProgressIndicator(),
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
