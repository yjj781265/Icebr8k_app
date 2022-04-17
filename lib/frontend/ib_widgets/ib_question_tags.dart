import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';

import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';

class IbQuestionTags extends StatelessWidget {
  final IbQuestionItemController _itemController;

  const IbQuestionTags(this._itemController);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(height: 30, child: tagList(context)),
    );
  }

  Widget tagList(BuildContext context) {
    return Obx(() {
      if (_itemController.isSample) {
        return Row(
            children: _itemController.rxIbQuestion.value.tags
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      elevation: 1,
                      backgroundColor: Theme.of(context).backgroundColor,
                      label: Text(
                        e,
                        style: const TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize),
                      ),
                    ),
                  ),
                )
                .toList());
      }
      return Row(
        children: _itemController.ibTags
            .map((element) => Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    elevation: 1,
                    backgroundColor: Theme.of(context).backgroundColor,
                    label: Text(
                      element.text,
                      style: const TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize),
                    ),
                    onPressed: () {},
                  ),
                ))
            .toList(),
      );
    });
  }
}
