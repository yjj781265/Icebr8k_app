import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbQuestionTags extends StatelessWidget {
  final IbQuestionItemController _itemController;

  const IbQuestionTags(this._itemController);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: tagList(context),
    );
  }

  Widget tagList(BuildContext context) {
    return Obx(() {
      if (_itemController.isSample && _itemController.isSubmitting.isTrue) {
        return Row(
            children: _itemController.rxIbQuestion.value.tagIds
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
