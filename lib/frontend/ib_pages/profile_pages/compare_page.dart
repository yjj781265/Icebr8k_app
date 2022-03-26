import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/compare_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ComparePage extends StatelessWidget {
  final CompareController _controller;

  const ComparePage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_controller.title),
      ),
      body: SafeArea(
        child: Obx(() {
          if (_controller.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }

          return SmartRefresher(
            enablePullUp: true,
            enablePullDown: false,
            onLoading: () async {
              await _controller.loadMore();
            },
            controller: _controller.refreshController,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return _handleQuestionType(
                    _controller.items.keys.toList()[index]);
              },
              itemCount: _controller.items.keys.toList().length,
            ),
          );
        }),
      ),
    );
  }

  Widget _handleQuestionType(IbQuestion ibQuestion) {
    final IbQuestionItemController itemController = Get.put(
        IbQuestionItemController(
            rxIbQuestion: ibQuestion.obs,
            rxIsExpanded: true.obs,
            ibAnswers: _controller.items[ibQuestion]),
        tag: _controller.items[ibQuestion].hashCode.toString());

    if (ibQuestion.questionType == IbQuestion.kMultipleChoice ||
        ibQuestion.questionType == IbQuestion.kMultipleChoicePic) {
      return IbMcQuestionCard(itemController);
    }
    return IbScQuestionCard(
      itemController,
    );
  }
}
