import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:liquid_swipe/liquid_swipe.dart';

class SetupPage extends StatelessWidget {
  SetupPage({Key? key}) : super(key: key);
  final SetUpController setUpController = Get.put(SetUpController());
  final MyAnsweredQuestionsController _myAnsweredQController = Get.find();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Scaffold(
      body: Obx(
        () {
          if (setUpController.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          } else {
            return WillPopScope(
              onWillPop: () async {
                if (Platform.isAndroid) {
                  await Get.find<AuthController>().signOut();
                }
                return true;
              },
              child: LiquidSwipe(
                onPageChangeCallback: (index) {
                  setUpController.currentPageIndex.value = index;
                },
                liquidController: setUpController.liquidController,
                fullTransitionValue:
                    IbConfig.kEventTriggerDelayInMillis.toDouble(),
                disableUserGesture: true,
                ignoreUserGestureWhileAnimating: true,
                enableLoop: false,
                pages: setUpController.pages,
              ),
            );
          }
        },
      ),
    );
  }
}
