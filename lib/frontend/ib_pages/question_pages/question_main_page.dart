import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';

import '../../../backend/models/ib_question.dart';
import '../../ib_widgets/ib_mc_question_card.dart';

class QuestionMainPage extends StatelessWidget {
  final IbQuestionItemController _controller;

  const QuestionMainPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.rxIbQuestion.value.question),
      ),
      body: SingleChildScrollView(child: _handleQuestionType(_controller.rxIbQuestion.value)),
    );
  }

  Widget _handleQuestionType(IbQuestion question) {
    final IbQuestionItemController itemController = Get.put(
        IbQuestionItemController(
            rxIbQuestion: question.obs, rxIsExpanded: false.obs),
        tag: question.id);

    if (question.questionType == IbQuestion.kMultipleChoice ||
        question.questionType == IbQuestion.kMultipleChoicePic) {
      return IbMcQuestionCard(itemController);
    }

    return IbScQuestionCard(itemController);
  }
}
