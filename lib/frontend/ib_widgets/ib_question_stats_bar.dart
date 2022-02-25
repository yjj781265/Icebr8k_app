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
    return Obx(
      () => AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
                onPressed: _itemController.isSample ? null : _handleOnStatsTap,
                icon: FaIcon(
                  FontAwesomeIcons.voteYea,
                  color: _itemController.rxIbAnswer != null
                      ? IbColors.primaryColor
                      : IbColors.lightGrey,
                  size: 16,
                ),
                label: Text(
                  _itemController.totalPolled.value.toString(),
                  style: TextStyle(
                      color: Theme.of(context).indicatorColor,
                      fontSize: IbConfig.kDescriptionTextSize),
                )),
            if (_itemController.rxIbQuestion.value.isCommentEnabled)
              TextButton.icon(
                  onPressed: _itemController.isSample
                      ? null
                      : () {
                          Get.to(() => CommentPage(Get.put(
                              CommentController(
                                  _itemController.rxIbQuestion.value.id),
                              tag: _itemController.rxIbQuestion.value.id)));
                        },
                  icon: FaIcon(
                    FontAwesomeIcons.comment,
                    color: _itemController.commented.isTrue
                        ? IbColors.darkPrimaryColor
                        : Colors.grey,
                    size: 16,
                  ),
                  label: Text(
                    IbUtils.statsShortString(_itemController.comments.value),
                    style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontSize: IbConfig.kDescriptionTextSize),
                  )),
            TextButton.icon(
              onPressed: _itemController.isSample ||
                      (_itemController.rxIbAnswer != null &&
                          _itemController.rxIbAnswer!.value.uid !=
                              IbUtils.getCurrentUid())
                  ? null
                  : () {
                      _itemController.updateLike();
                    },
              icon: FaIcon(
                FontAwesomeIcons.thumbsUp,
                color: _itemController.liked.isTrue
                    ? IbColors.accentColor
                    : IbColors.lightGrey,
                size: 16,
              ),
              label: Text(
                _itemController.likes.value.toString(),
                style: TextStyle(
                    color: Theme.of(context).indicatorColor,
                    fontSize: IbConfig.kDescriptionTextSize),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOnStatsTap() async {
    if (_itemController.voted.isFalse) {
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
