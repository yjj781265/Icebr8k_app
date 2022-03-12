import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/asked_questions_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AskedPage extends StatelessWidget {
  final AskedQuestionsController _controller;
  final ScrollController _scrollController = ScrollController();

  AskedPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questions Asked'),
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
              if (index == 0) {
                // return the header
                if (_controller.showPublicOnly) {
                  return Align(
                    child: Text(
                      'asked_question_ps'.tr,
                      style: const TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                          color: IbColors.lightGrey),
                    ),
                  );
                }
                return const SizedBox();
              }
              index -= 1;
              return _handleQuestionType(_controller.createdQuestions[index]);
            },
            itemCount: _controller.createdQuestions.length + 1,
          ),
        );
      }),
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