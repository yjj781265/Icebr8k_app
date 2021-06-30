import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_pages/splash_page.dart';
import 'package:icebr8k/frontend/ib_strings.dart';
import 'package:icebr8k/frontend/ib_themes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
}
