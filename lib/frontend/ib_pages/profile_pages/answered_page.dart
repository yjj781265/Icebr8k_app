import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/answered_question_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AnsweredPage extends StatelessWidget {
  final AnsweredQuestionController _controller;
  final ScrollController _scrollController = ScrollController();

  AnsweredPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions Answered'),
      ),
      body: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }

        return SmartRefresher(
          controller: _controller.refreshController,
          scrollController: _scrollController,
          enablePullDown: false,
          enablePullUp: true,
          onLoading: () async {
            await _controller.loadMore();
          },
          child: ListView.builder(
            controller: _scrollController,
            itemBuilder: (context, index) {
              return _handleQuestionType(_controller.answeredQs[index]);
            },
            itemCount: _controller.answeredQs.length,
          ),
        );
      }),
    );
  }

  Widget _handleQuestionType(AnsweredQuestionItem item) {
    final IbQuestionItemController itemController = Get.put(
        IbQuestionItemController(
          rxIbQuestion: (item.ibQuestion).obs,
          rxIsExpanded: false.obs,
        )..rxIbAnswer = item.ibAnswer.obs,
        tag: item.ibQuestion.id);

    if (item.ibQuestion.questionType == IbQuestion.kMultipleChoice ||
        item.ibQuestion.questionType == IbQuestion.kMultipleChoicePic) {
      return IbMcQuestionCard(itemController);
    }

    return IbScQuestionCard(itemController);
  }
}
