import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:lottie/lottie.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../ib_colors.dart';

class QuestionTab extends StatelessWidget {
  QuestionTab({Key? key}) : super(key: key);
  final _ibQuestionController = Get.find<IbQuestionController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_ibQuestionController.isLoading.isTrue) {
        return const Center(child: IbProgressIndicator());
      }

      if (_ibQuestionController.isLoading.isFalse &&
          _ibQuestionController.ibQuestions.isEmpty) {
        return Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
                width: 100,
                height: 100,
                child: Lottie.asset('assets/images/question.json')),
            const Text('You have answered all questions!'),
            TextButton(
                onPressed: () async =>
                    _ibQuestionController.refreshEverything(),
                child: const Text('Refresh'))
          ],
        ));
      }

      return SmartRefresher(
          physics: const AlwaysScrollableScrollPhysics(),
          footer: const ClassicFooter(
            loadStyle: LoadStyle.ShowWhenLoading,
            noDataText: '',
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
          header: const WaterDropMaterialHeader(
            backgroundColor: IbColors.primaryColor,
          ),
          onRefresh: () async {
            await _ibQuestionController.refreshEverything();
          },
          controller: _ibQuestionController.refreshController,
          enablePullUp: true,
          onLoading: () async {
            await Future.delayed(const Duration(seconds: 1),
                _ibQuestionController.loadMoreQuestion);
          },
          child: _handleBodyWidget());
    });
  }

  Widget _handleBodyWidget() {
    return ListView.builder(
        itemCount: _ibQuestionController.ibQuestions.length,
        itemBuilder: (context, index) {
          final _ibQuestion = _ibQuestionController.ibQuestions[index];
          if (_ibQuestion.questionType == IbQuestion.kScale) {
            return IbScQuestionCard(Get.put(
                IbQuestionItemController(
                    rxIsExpanded: false.obs,
                    rxIbQuestion: _ibQuestion.obs,
                    disableAvatarOnTouch:
                        IbUtils.getCurrentUid()! == _ibQuestion.creatorId),
                tag: _ibQuestion.id));
          }

          return IbMcQuestionCard(Get.put(
              IbQuestionItemController(
                rxIsExpanded: false.obs,
                disableAvatarOnTouch:
                    IbUtils.getCurrentUid()! == _ibQuestion.creatorId,
                rxIbQuestion: _ibQuestion.obs,
              ),
              tag: _ibQuestion.id));
        });
  }
}
