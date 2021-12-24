import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
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
                disabled: _controller.isSample ||
                    _controller.selectedChoiceId.isEmpty ||
                    (_controller.rxIbAnswer != null &&
                        _controller.rxIbAnswer!.value.uid !=
                            IbUtils.getCurrentUid()) ||
                    _controller.rxIbAnswer != null &&
                        _controller.rxIbAnswer!.value.choiceId ==
                            _controller.selectedChoiceId.value ||
                    _controller.isAnswering.isTrue,
                onPressed: () async {
                  await _controller.onVote();
                },
                textTrKey: _controller.isAnswering.isTrue
                    ? 'voting'
                    : _controller.showResult.isTrue
                        ? 'change_vote'
                        : 'vote',
                color: IbColors.primaryColor,
              ),
            ),
            if (_controller.rxIbQuestion.value.isCommentEnabled)
              Expanded(
                child: IbElevatedButton(
                  disabled: _controller.isSample,
                  onPressed: () {},
                  textTrKey: 'comment',
                ),
              )
          ],
        ),
      );
    });
  }
}
