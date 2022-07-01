import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';

import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';

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
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: AutoSizeText(
              _controller.rxIbQuestion.value.question,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              minFontSize: IbConfig.kSecondaryTextSize,
              maxFontSize: IbConfig.kPageTitleSize,
              style: const TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          if (_controller.rxIbQuestion.value.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
              child: IbDescriptionText(
                text: _controller.rxIbQuestion.value.description,
              ),
            ),
        ],
      ),
    );
  }
}
