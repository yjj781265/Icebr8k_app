import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

class SetupPage extends GetView<MyAnsweredQuestionsController> {
  SetupPage({Key? key}) : super(key: key);
  final SetUpController setUpController = Get.put(SetUpController());

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(statusBarColor: Colors.transparent));

    return Container(
      color: IbColors.lightBlue,
      child: Obx(
        () {
          if (setUpController.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          } else {
            return WillPopScope(
              onWillPop: () async {
                await Get.find<AuthController>().signOut();
                return true;
              },
              child: ListView.builder(
                controller: setUpController.autoScrollController,
                physics: const NeverScrollableScrollPhysics(),
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return AutoScrollTag(
                    key: ValueKey(index),
                    controller: setUpController.autoScrollController,
                    index: index,
                    child: SizedBox(
                      height: Get.height,
                      width: Get.width,
                      child: setUpController.pages[index],
                    ),
                  );
                },
                itemCount: setUpController.pages.length,
              ),
            );
          }
        },
      ),
    );
  }
}
