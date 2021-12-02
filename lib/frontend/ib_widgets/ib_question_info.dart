import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbQuestionInfo extends StatelessWidget {
  final IbQuestionItemController _controller;

  const IbQuestionInfo(this._controller);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
          child: Text(
            _controller.rxIbQuestion.value.question,
            style: const TextStyle(
                fontSize: IbConfig.kPageTitleSize, fontWeight: FontWeight.bold),
          ),
        ),
        if (_controller.rxIbQuestion.value.description.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Obx(
              () => Text(
                _controller.rxIbQuestion.value.description.trim(),
                overflow: _controller.rxIsExpanded.value
                    ? null
                    : TextOverflow.ellipsis,
                style: const TextStyle(fontSize: IbConfig.kSecondaryTextSize),
              ),
            ),
          ),
      ],
    );
  }
}
