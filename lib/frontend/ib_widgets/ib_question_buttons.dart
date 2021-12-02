import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';

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
                  disabled: _controller.isSample,
                  onPressed: () {},
                  textTrKey: _controller.isAnswering.isFalse
                      ? 'vote'
                      : _controller.showResult.isTrue
                          ? 'change_vote'
                          : 'voting',
                ),
              ),
              if (_controller.rxIbQuestion.value.isCommentEnabled)
                Expanded(
                  child: IbElevatedButton(
                    disabled: _controller.isSample,
                    color: IbColors.primaryColor,
                    onPressed: () {},
                    textTrKey: 'comment',
                  ),
                )
            ],
          ));
    });
  }
}
