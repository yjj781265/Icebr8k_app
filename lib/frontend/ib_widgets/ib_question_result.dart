import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_result_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class IbQuestionResult extends StatelessWidget {
  final IbQuestionResultController _controller;

  const IbQuestionResult(this._controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.isTrue) {
        return const Center(
          child: IbProgressIndicator(),
        );
      }
      return Scrollbar(
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _controller.resultMap.keys
                  .map((e) => IbQuestionResultItem(
                      controller: _controller, ibChoice: e))
                  .toList()),
        ),
      );
    });
  }
}

class IbQuestionResultItem extends StatelessWidget {
  final IbQuestionResultController controller;
  final IbChoice ibChoice;
  const IbQuestionResultItem(
      {required this.controller, required this.ibChoice, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int count = controller.itemController.countMap![ibChoice] ?? 0;

    if (count == 0) {
      return const SizedBox();
    }

    return SizedBox(
      height: 90,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            _handleItemHeader(count),
            Container(
              height: 72,
              width: 1,
              color: IbColors.lightGrey,
            ),
            Expanded(
              child: _handleItemList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _handleItemHeader(int count) {
    if (controller.itemController.countMap == null) {
      return const SizedBox();
    }
    final IbQuestion ibQuestion = controller.itemController.rxIbQuestion.value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ibQuestion.questionType == IbQuestion.kMultipleChoice ||
              ibQuestion.questionType == IbQuestion.kMultipleChoicePic ||
              ibQuestion.questionType == IbQuestion.kScale)
            SizedBox(
              width: 80,
              child: Text(
                ibChoice.content!,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
          if (ibQuestion.questionType == IbQuestion.kPic)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                fadeOutDuration: const Duration(milliseconds: 100),
                placeholderFadeInDuration: const Duration(milliseconds: 100),
                fadeInDuration: const Duration(milliseconds: 100),
                fit: BoxFit.fill,
                imageUrl: ibChoice.url!,
                height: 56,
                width: 56,
              ),
            ),
          const SizedBox(
            width: 8,
          ),
          SizedBox(
            width: 80,
            child: Text(
              '${IbUtils.statsShortString(count)} ${count == 1 ? 'vote' : 'votes'}',
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: IbConfig.kSecondaryTextSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _handleItemList() {
    final RxList<ResultItemModel>? list = controller.resultMap[ibChoice];
    if (list == null || list.isEmpty) {
      return const SizedBox();
    }

    return Obx(() => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final model = list[index];
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  IbUserAvatar(
                    avatarUrl: model.user.avatarUrl,
                    uid: model.user.id,
                    compScore: model.compScore,
                  ),
                  Container(
                      width: 60,
                      alignment: Alignment.center,
                      child: Text(model.user.username,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize,
                          ))),
                ],
              ),
            );
          },
          itemCount: list.length,
        ));
  }
}
