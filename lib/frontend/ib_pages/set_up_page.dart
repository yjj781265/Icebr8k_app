import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/screen_one.dart';
import 'package:icebr8k/frontend/ib_pages/screen_three.dart';
import 'package:icebr8k/frontend/ib_pages/screen_two.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class SetupPage extends StatelessWidget {
  SetupPage({Key? key}) : super(key: key);
  final SetUpController _setUpController = Get.put(SetUpController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      body: LiquidSwipe(
        onPageChangeCallback: (index) {
          _setUpController.currentPage.value = index;
        },
        liquidController: _setUpController.liquidController,
        fullTransitionValue: IbConfig.kEventTriggerDelayInMillis.toDouble(),
        disableUserGesture: true,
        ignoreUserGestureWhileAnimating: true,
        enableLoop: false,
        pages: [
          ScreenOne(),
          ScreenTwo(),
          ScreenThree(),
        ],
      ),
    );
  }
}
