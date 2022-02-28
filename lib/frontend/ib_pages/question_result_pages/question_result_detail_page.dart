import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_result_controller.dart';

class QuestionResultDetailPage extends StatelessWidget {
  final QuestionResultDetailPageController _pageController;

  QuestionResultDetailPage(this._pageController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            children: [
              Text(
                  '${_pageController.itemController.countMap[_pageController.ibChoice] ?? 0} votes'),
            ],
          ),
        ),
      ),
    );
  }
}
