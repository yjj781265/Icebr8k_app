import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class SetupPage extends StatelessWidget {
  final List<Widget> pages;
  SetupPage({Key? key, required this.pages}) : super(key: key);
  final SetUpController _setUpController = Get.find();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      body: LiquidSwipe(
        onPageChangeCallback: (index) {
          _setUpController.currentPageIndex.value = index;
        },
        liquidController: _setUpController.liquidController,
        fullTransitionValue: IbConfig.kEventTriggerDelayInMillis.toDouble(),
        disableUserGesture: true,
        ignoreUserGestureWhileAnimating: true,
        enableLoop: false,
        pages: pages,
      ),
    );
  }
}
