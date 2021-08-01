import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';

import '../ib_colors.dart';

class QuestionPage extends StatelessWidget {
  QuestionPage({Key? key}) : super(key: key);
  final _ibQuestionController = Get.find<IbQuestionController>();
  final _carouselController = CarouselController();
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_ibQuestionController.isLoading.isTrue) {
        return Container(
          color: IbColors.lightBlue,
          child: const Center(
            child: IbProgressIndicator(),
          ),
        );
      }

      if (_ibQuestionController.ibQuestions.isEmpty) {
        return Container(
            color: IbColors.lightBlue,
            child:
                const Center(child: Text('You have answered all questions!')));
      }

      return Container(
        color: IbColors.lightBlue,
        child: CarouselSlider(
          carouselController: _carouselController,
          options: CarouselOptions(
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                if (index == _ibQuestionController.ibQuestions.length - 1) {
                  _ibQuestionController.loadMoreQuestions();
                }
              },
              viewportFraction: 0.95,
              height: Get.height),
          items: _ibQuestionController.ibQuestions.map((_ibQuestion) {
            if (_ibQuestion.questionType == IbQuestion.kScale) {
              return Center(
                child: IbScQuestionCard(Get.put(
                    IbQuestionItemController(_ibQuestion),
                    tag: _ibQuestion.id)),
              );
            }

            return IbMcQuestionCard(Get.put(
                IbQuestionItemController(_ibQuestion),
                tag: _ibQuestion.id));
          }).toList(),
        ),
      );
    });
  }
}
