import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/home_page.dart';
import 'package:icebr8k/frontend/ib_pages/sign_in_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

class SplashPage extends GetView<AuthController> {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
            () => navigateToCorrectPage())
        .then((_) => print('leaving splash page'));
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

  void navigateToCorrectPage() {
    if (controller.isSignedIn.value) {
      print('to home page');
      Get.offAll(
        HomePage(),
        transition: Transition.fadeIn,
      );
    } else {
      Get.offAll(SignInPage(),
          transition: Transition.fadeIn,
          duration: const Duration(
              milliseconds: IbConfig.kEventTriggerDelayInMillis));
    }
  }
}
