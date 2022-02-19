import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';

class IbQuestionInfo extends StatelessWidget {
  final IbQuestionItemController _controller;

  const IbQuestionInfo(this._controller);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
            child: Text(
              _controller.rxIbQuestion.value.question,
              style: const TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          if (_controller.rxIbQuestion.value.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
              child: IbDescriptionText(
                text: _controller.rxIbQuestion.value.description,
              ),
            ),
          if (_controller.rxIbQuestion.value.endpoints != null &&
              _controller.rxIbQuestion.value.endpoints!.length == 2 &&
              _controller.showComparison.isTrue)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16),
              child: Text(
                '1: ${_controller.rxIbQuestion.value.endpoints?.first.content}  5:${_controller.rxIbQuestion.value.endpoints?.last.content}',
                overflow: _controller.rxIsExpanded.value
                    ? null
                    : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: IbConfig.kSecondaryTextSize),
              ),
            ),
        ],
      ),
    );
  }
}
