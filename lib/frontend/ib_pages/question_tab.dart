import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../ib_colors.dart';

class QuestionTab extends StatelessWidget {
  QuestionTab({Key? key}) : super(key: key);
  final _ibQuestionController = Get.find<IbQuestionController>();
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

      return Container(
          color: IbColors.lightBlue,
          child: SmartRefresher(
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
            header: const ClassicHeader(
              textStyle: TextStyle(color: IbColors.primaryColor),
              failedIcon: Icon(
                Icons.error_outline,
                color: IbColors.errorRed,
              ),
              completeIcon: Icon(
                Icons.check_circle_outline,
                color: IbColors.accentColor,
              ),
              refreshingIcon: IbProgressIndicator(
                width: 24,
                height: 24,
                padding: 0,
              ),
            ),
            onRefresh: () async {
              await Get.find<IbQuestionController>().refreshEverything();
              _refreshController.refreshCompleted();
            },
            controller: _refreshController,
            enablePullUp: true,
            onLoading: () async {
              if (!_ibQuestionController.hasMore) {
                _refreshController.loadNoData();
                return;
              }

              await _ibQuestionController.loadMoreQuestion();
              _refreshController.loadComplete();
            },
            child: ListView.builder(
                itemCount: _ibQuestionController.ibQuestions.length,
                itemBuilder: (context, index) {
                  if (_ibQuestionController.isLoading.isFalse &&
                      _ibQuestionController.ibQuestions.isEmpty) {
                    return const Center(
                        child: Text('You have answered all questions!'));
                  }

                  final _ibQuestion = _ibQuestionController.ibQuestions[index];
                  if (_ibQuestion.questionType == IbQuestion.kScale) {
                    return IbScQuestionCard(Get.put(
                        IbQuestionItemController(
                            ibQuestion: _ibQuestion,
                            disableAvatarOnTouch: IbUtils.getCurrentUid()! ==
                                _ibQuestion.creatorId),
                        tag: _ibQuestion.id));
                  }

                  return IbMcQuestionCard(Get.put(
                      IbQuestionItemController(
                        disableAvatarOnTouch:
                            IbUtils.getCurrentUid()! == _ibQuestion.creatorId,
                        ibQuestion: _ibQuestion,
                      ),
                      tag: _ibQuestion.id));
                }),
          ));
    });
  }
}
