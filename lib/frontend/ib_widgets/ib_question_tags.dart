import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/tag_page.dart';

import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';

class IbQuestionTags extends StatelessWidget {
  final IbQuestionItemController _itemController;
  final String highlightText;

  const IbQuestionTags(this._itemController, {this.highlightText = ''});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: tagList(context),
    );
  }

  Widget tagList(BuildContext context) {
    return Obx(() {
      if (_itemController.isSample) {
        return Row(
            children: _itemController.rxIbQuestion.value.tags
                .map(
                  (e) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        border:
                            Border.all(color: Theme.of(context).indicatorColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
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
            .map(
              (element) => Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        border:
                            Border.all(color: Theme.of(context).indicatorColor),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(element.text,
                          style: TextStyle(
                              fontWeight: element.text == highlightText
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: IbConfig.kDescriptionTextSize)),
                    ),
                  ),
                  Positioned.fill(
                      child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onTap: () {
                        Get.to(() =>
                            TagPage(Get.put(TagPageController(element.text))));
                      },
                    ),
                  ))
                ],
              ),
            )
            .toList(),
      );
    });
  }
}
