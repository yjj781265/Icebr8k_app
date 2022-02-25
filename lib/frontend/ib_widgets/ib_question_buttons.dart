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
            // don't show answer button once user is answered the quiz or poll is closed
            if (_controller.rxIbQuestion.value.isQuiz &&
                    _controller.voted.isTrue ||
                (DateTime.now().millisecondsSinceEpoch >
                        _controller.rxIbQuestion.value.endTimeInMs &&
                    _controller.rxIbQuestion.value.endTimeInMs > 0))
              const SizedBox()
            else
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
                        CommentController(_controller.rxIbQuestion.value.id),
                        tag: _controller.rxIbQuestion.value.id)));
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
          : _controller.voted.isTrue
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
        _controller.voted.isTrue && _controller.rxIbQuestion.value.isQuiz;
  }
}
