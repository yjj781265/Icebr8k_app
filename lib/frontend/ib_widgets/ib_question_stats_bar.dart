import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/comment_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_result_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/comment_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_question_result.dart';

import '../ib_config.dart';
import '../ib_utils.dart';

/// show action icons with like, poll size, comment
class IbQuestionStatsBar extends StatelessWidget {
  final IbQuestionItemController _itemController;

  const IbQuestionStatsBar(this._itemController);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Material(
        color: Colors.transparent,
        child: SingleChildScrollView(
          child: Obx(
            () => AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    onTap: _itemController.isSample ? null : _handleOnStatsTap,
                    child: Padding(
                      padding:
                          const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                      child: Row(
                        children: [
                          FaIcon(
                            Icons.poll_outlined,
                            color: _itemController.rxIbAnswer != null
                                ? IbColors.primaryColor
                                : IbColors.lightGrey,
                            size: 22,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            _itemController.totalPolled.value.toString(),
                            style: const TextStyle(
                                fontSize: IbConfig.kDescriptionTextSize),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_itemController.rxIbQuestion.value.isCommentEnabled)
                    InkWell(
                      onTap: _itemController.isSample
                          ? null
                          : () {
                              Get.to(() => CommentPage(Get.put(
                                  CommentController(
                                      _itemController.rxIbQuestion.value))));
                            },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            FaIcon(
                              FontAwesomeIcons.comment,
                              color: _itemController.commented.isTrue
                                  ? IbColors.darkPrimaryColor
                                  : Colors.grey,
                              size: 19,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              IbUtils.statsShortString(
                                  _itemController.comments.value),
                              style: const TextStyle(
                                  fontSize: IbConfig.kDescriptionTextSize),
                            ),
                          ],
                        ),
                      ),
                    ),
                  InkWell(
                    onTap: _itemController.isSample ||
                            (_itemController.rxIbAnswer != null &&
                                _itemController.rxIbAnswer!.value.uid !=
                                    IbUtils.getCurrentUid())
                        ? null
                        : () {
                            _itemController.updateLike();
                          },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.thumbsUp,
                            color: _itemController.liked.isTrue
                                ? IbColors.accentColor
                                : IbColors.lightGrey,
                            size: 19,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            _itemController.likes.value.toString(),
                            style: const TextStyle(
                                fontSize: IbConfig.kDescriptionTextSize),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleOnStatsTap() async {
    if (_itemController.showResult.isFalse) {
      IbUtils.showSimpleSnackBar(
          msg: 'You need to answer the poll in order to see the result.',
          backgroundColor: IbColors.primaryColor);
      return;
    }

    final bool isRegistered = Get.isRegistered<IbQuestionResultController>(
        tag: _itemController.rxIbQuestion.value.id);
    late IbQuestionResultController _controller;

    if (isRegistered) {
      _controller = Get.find<IbQuestionResultController>(
          tag: _itemController.rxIbQuestion.value.id);
      _controller.initResultMap();
    } else {
      _controller = Get.put(IbQuestionResultController(_itemController),
          tag: _itemController.rxIbQuestion.value.id);
    }

    Get.bottomSheet(
        IbCard(
            child: SizedBox(
          height: Get.height * 0.6,
          child: IbQuestionResult(_controller),
        )),
        ignoreSafeArea: false,
        isScrollControlled: false);
  }
}
