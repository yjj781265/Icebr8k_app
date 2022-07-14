import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/question_pages/question_main_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../../backend/controllers/user_controllers/question_main_controller.dart';

class IbQuestionSnippetCard extends StatelessWidget {
  final IbQuestion question;

  const IbQuestionSnippetCard(this.question);

  @override
  Widget build(BuildContext context) {
    return IbCard(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListTile(
        onTap: () {
          Get.to(() => QuestionMainPage(
                Get.put(QuestionMainController(
                  Get.put(
                      IbQuestionItemController(
                          isShowCase: false.obs,
                          rxIsSample: false.obs,
                          rxIbQuestion: question.obs,
                          rxIsExpanded: true.obs),
                      tag: IbUtils().getUniqueId()),
                )),
              ));
        },
        title: AutoSizeText(
          question.question,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          minFontSize: IbConfig.kNormalTextSize,
          style: const TextStyle(
              fontSize: IbConfig.kPageTitleSize, fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            '${question.pollSize} Vote(s)',
            style: const TextStyle(
                color: IbColors.lightGrey,
                fontSize: IbConfig.kSecondaryTextSize),
          ),
        ),
        trailing: _getQuestionIcon(),
      ),
    ));
  }

  Icon _getQuestionIcon() {
    switch (question.questionType) {
      case QuestionType.multipleChoice:
        return const Icon(
          FontAwesomeIcons.bars,
          color: IbColors.primaryColor,
        );
      case QuestionType.multipleChoicePic:
        return const Icon(FontAwesomeIcons.listUl,
            color: IbColors.primaryColor);
      case QuestionType.scaleOne:
      case QuestionType.scaleTwo:
      case QuestionType.scaleThree:
        return const Icon(FontAwesomeIcons.star,
            size: 16, color: IbColors.primaryColor);
    }
  }
}
