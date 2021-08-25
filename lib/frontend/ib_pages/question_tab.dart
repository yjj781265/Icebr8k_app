import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../ib_colors.dart';

class QuestionTab extends StatelessWidget {
  QuestionTab({Key? key}) : super(key: key);
  final _ibQuestionController = Get.find<IbQuestionController>();
  final _carouselController = CarouselController();
  final _refreshController = RefreshController();
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
          child: SmartRefresher(
            controller: _refreshController,
            footer: const ClassicFooter(
              textStyle: TextStyle(color: IbColors.primaryColor),
              failedIcon: Icon(
                Icons.error_outline,
                color: IbColors.errorRed,
              ),
              loadingIcon: IbProgressIndicator(
                width: 24,
                height: 24,
                padding: 0,
              ),
            ),
            enablePullUp: true,
            enablePullDown: false,
            scrollDirection: Axis.horizontal,
            onLoading: () async {
              await _ibQuestionController.queryQuestionsFromDb();
              if (_ibQuestionController.lastDocSnapShot == null) {
                _refreshController.loadNoData();
                return;
              }
              _refreshController.loadComplete();
            },
            child: CarouselSlider.builder(
                itemCount: _ibQuestionController.ibQuestions.length,
                carouselController: _carouselController,
                options: CarouselOptions(
                    enableInfiniteScroll: false,
                    onPageChanged: (index, reason) {
                      print('page changed to index $index');
                      if (index ==
                          _ibQuestionController.ibQuestions.length - 1) {
                        //_ibQuestionController.loadQuestions();
                      }
                    },
                    viewportFraction: 0.95,
                    height: Get.height),
                itemBuilder: (context, index, pageViewIndex) {
                  final _ibQuestion = _ibQuestionController.ibQuestions[index];
                  if (_ibQuestion.questionType == IbQuestion.kScale) {
                    return Center(
                        child: IbScQuestionCard(Get.put(
                            IbQuestionItemController(ibQuestion: _ibQuestion),
                            tag: _ibQuestion.id)));
                  }

                  return IbMcQuestionCard(Get.put(
                      IbQuestionItemController(
                        ibQuestion: _ibQuestion,
                      ),
                      tag: _ibQuestion.id));
                }),
          ));
    });
  }
}
