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
    return AspectRatio(
      aspectRatio: 0.618,
      child: IbCard(
          radius: 8,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: AutoSizeText(
                  question.question,
                  textAlign: TextAlign.center,
                  maxLines: 8,
                  style: const TextStyle(
                      fontSize: IbConfig.kPageTitleSize,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: _getQuestionIcon(),
                ),
              ),
              Positioned.fill(
                  child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onTap: () {
                    Get.to(() => QuestionMainPage(
                          Get.put(QuestionMainController(
                            Get.put(
                                IbQuestionItemController(
                                    isShowCase: false.obs,
                                    rxIsSample: false.obs,
                                    rxIbQuestion: question.obs,
                                    rxIsExpanded: true.obs),
                                tag: IbUtils.getUniqueId()),
                          )),
                        ));
                  },
                ),
              ))
            ],
          )),
    );
  }

  Icon _getQuestionIcon() {
    switch (question.questionType) {
      case QuestionType.multipleChoice:
        return const Icon(
          FontAwesomeIcons.bars,
          size: 16,
          color: IbColors.primaryColor,
        );
      case QuestionType.multipleChoicePic:
        return const Icon(FontAwesomeIcons.listUl,
            size: 16, color: IbColors.primaryColor);
      case QuestionType.scaleOne:
      case QuestionType.scaleTwo:
      case QuestionType.scaleThree:
        return const Icon(FontAwesomeIcons.star,
            size: 16, color: IbColors.primaryColor);
    }
  }
}
