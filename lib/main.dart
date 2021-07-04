import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:lottie/lottie.dart';

import 'ib_config.dart';
import 'ib_pages/splash_page.dart';
import 'ib_strings.dart';
import 'ib_themes.dart';
import 'ib_widgets/ib_progress_indicator.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: IbColors.lightBlue),
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _somethingWrong();
        }
        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          print('Firebase init success');
          return GetMaterialApp(
            defaultTransition: Transition.cupertino,
            enableLog: false,
            debugShowCheckedModeBanner: false,
            home: const SplashPage(),
            translations: IbStrings(),
            locale: const Locale('en', 'US'),
            theme: IbThemes.lightTheme,
          );
        }

        return _loading();
      },
    );
  }
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
