import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/set_up_page.dart';
import 'package:icebr8k/frontend/ib_pages/sign_in_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';

import '../ib_colors.dart';
import 'home_page.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);
  final controller = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: !IbLocalStorageService()
                  .isCustomKeyTrue(IbLocalStorageService.isLightModeCustomKey)
              ? Colors.black
              : IbColors.lightBlue),
    );
    Future.delayed(
        const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
        () => navigateToCorrectPage());

    return Scaffold(
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
      final bool isUserNameMissing = await IbUserDbService()
          .isUsernameMissing(controller.firebaseUser!.uid);
      final bool isAvatarUrlMissing = await IbUserDbService()
          .isAvatarUrlMissing(controller.firebaseUser!.uid);
      final questions = await IbUserDbService()
          .queryUnAnsweredFirst8Q(controller.firebaseUser!.uid);

      if (questions.isNotEmpty || isUserNameMissing || isAvatarUrlMissing) {
        print('SplashPage: setup is needed, nav to setup page');

        Get.offAll(
          () => SetupPage(),
          transition: Transition.fadeIn,
        );
      } else {
        print('SplashPage: nav to homepage, setup is done');
        Get.offAll(
          () => HomePage(),
          binding: HomeBinding(),
          transition: Transition.fadeIn,
        );
      }
    } else {
      print('SplashPage: firebase is null, nav to sign in page');
      Get.offAll(() => SignInPage(),
          transition: Transition.fadeIn,
          duration: const Duration(
              milliseconds: IbConfig.kEventTriggerDelayInMillis));
    }
  }
}
