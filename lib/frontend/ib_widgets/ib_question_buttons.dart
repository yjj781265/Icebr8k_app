import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/comment_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_pages/comment_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../ib_colors.dart';
import 'ib_elevated_button.dart';

class IbQuestionButtons extends StatelessWidget {
  final IbQuestionItemController _controller;

  const IbQuestionButtons(this._controller);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SizedBox(
        height: 56,
        child: Row(
          children: [
            Expanded(
              child: IbElevatedButton(
                disabled: _handleVoteButtonDisableState(),
                onPressed: () async {
                  await _controller.onVote();
                },
                textTrKey: _handleVoteButtonText(),
                color: IbColors.primaryColor,
              ),
            ),
            if (_controller.rxIbQuestion.value.isCommentEnabled)
              Expanded(
                child: IbElevatedButton(
                  disabled: _controller.isSample,
                  onPressed: () {
                    Get.to(() => CommentPage(Get.put(
                        CommentController(_controller.rxIbQuestion.value))));
                  },
                  textTrKey: 'comment',
                ),
              )
          ],
        ),
      );
    });
  }

  String _handleVoteButtonText() {
    if (_controller.rxIbQuestion.value.isQuiz) {
      return _controller.isAnswering.isTrue ? 'voting' : 'answer';
    } else {
      return _controller.isAnswering.isTrue
          ? 'voting'
          : _controller.showResult.isTrue
              ? 'change_vote'
              : 'vote';
    }
  }

  bool _handleVoteButtonDisableState() {
    return _controller.isSample ||
        _controller.selectedChoiceId.isEmpty ||
        (_controller.rxIbAnswer != null &&
            _controller.rxIbAnswer!.value.uid != IbUtils.getCurrentUid()) ||
        _controller.rxIbAnswer != null &&
            _controller.rxIbAnswer!.value.choiceId ==
                _controller.selectedChoiceId.value ||
        _controller.isAnswering.isTrue ||
        _controller.showResult.isTrue && _controller.rxIbQuestion.value.isQuiz;
  }
}
