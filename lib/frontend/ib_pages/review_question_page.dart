import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';

class ReviewQuestionPage extends StatelessWidget {
  final IbQuestion question;
  const ReviewQuestionPage({Key? key, required this.question})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review your question'),
      ),
      body: Center(child: _handleQuestionType()),
    );
  }

  Widget _handleQuestionType() {
    if (question.questionType == IbQuestion.kMultipleChoice) {
      return IbMcQuestionCard(
        Get.put(
            IbQuestionItemController(
              ibQuestion: question,
              isSample: true,
            ),
            tag: 'sample${question.id}'),
      );
    }
    return IbScQuestionCard(
      Get.put(
          IbQuestionItemController(
            ibQuestion: question,
            isSample: true,
          ),
          tag: 'sample${question.id}'),
    );
  }
}
