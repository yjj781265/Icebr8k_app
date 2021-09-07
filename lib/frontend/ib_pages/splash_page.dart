import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/set_up_page.dart';
import 'package:icebr8k/frontend/ib_pages/sign_in_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import 'home_page.dart';

class SplashPage extends GetView<AuthController> {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future.delayed(
        const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
        () => navigateToCorrectPage());

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

  Future<void> navigateToCorrectPage() async {
    if (controller.firebaseUser != null) {
      final bool isSetupNeeded = await IbUserDbService()
          .isUsernameMissing(controller.firebaseUser!.uid);
      if (isSetupNeeded) {
        Get.offAll(
          () => SetupPage(),
          transition: Transition.fadeIn,
        );
      } else {
        Get.offAll(
          () => HomePage(),
          binding: HomeBinding(),
          transition: Transition.fadeIn,
        );
      }
    } else {
      Get.offAll(() => SignInPage(),
          transition: Transition.fadeIn,
          duration: const Duration(
              milliseconds: IbConfig.kEventTriggerDelayInMillis));
    }
  }
}
