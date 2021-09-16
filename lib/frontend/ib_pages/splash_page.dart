import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/screen_one.dart';
import 'package:icebr8k/frontend/ib_pages/screen_three.dart';
import 'package:icebr8k/frontend/ib_pages/screen_two.dart';
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
      final List<Widget> pages = [];
      final bool isUserNameMissing = await IbUserDbService()
          .isUsernameMissing(controller.firebaseUser!.uid);
      final bool isAvatarUrlMissing = await IbUserDbService()
          .isAvatarUrlMissing(controller.firebaseUser!.uid);
      final questions = await IbUserDbService()
          .queryUnAnsweredFirst8Q(controller.firebaseUser!.uid);
      final _controller = Get.put(SetUpController());
      if (isUserNameMissing) {
        pages.add(ScreenOne());
      }

      if (isAvatarUrlMissing) {
        pages.add(ScreenTwo());
      }

      if (questions.isNotEmpty) {
        _controller.ibQuestions.value = questions;
        pages.add(ScreenThree());
      }

      if (pages.isNotEmpty) {
        _controller.totalPageSize.value = pages.length;
        Get.offAll(
          () => SetupPage(
            pages: pages,
          ),
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
