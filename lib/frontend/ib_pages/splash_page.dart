import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import 'sign_in_page.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final task = Future.delayed(
        const Duration(seconds: 2),
        () => Get.offAll(const SignInPage(),
            transition: Transition.fadeIn,
            duration: const Duration(microseconds: 500)));
    task.then((value) => print("Go to sign in page"));

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: IbColors.lightBlue),
    );

    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      body: Center(
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
}
