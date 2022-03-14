import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/question_result_pages/question_result_main_page.dart';

import '../../backend/controllers/user_controllers/comment_controller.dart';
import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';
import '../ib_config.dart';
import '../ib_pages/comment_pages/comment_page.dart';
import '../ib_utils.dart';

/// show action icons with like, poll size, comment
class IbQuestionStatsBar extends StatelessWidget {
  final IbQuestionItemController _itemController;
  const IbQuestionStatsBar(this._itemController);

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
                onPressed: _itemController.isSample ? null : _handleOnStatsTap,
                icon: FaIcon(
                  FontAwesomeIcons.voteYea,
                  color: _itemController.rxIbAnswer != null
                      ? (_itemController.rxIbAnswer != null &&
                              _itemController.rxIbAnswer!.value.isPublic
                          ? IbColors.primaryColor
                          : Colors.black)
                      : IbColors.lightGrey,
                  size: 16,
                ),
                label: Text(
                  _itemController.rxIbQuestion.value.pollSize.toString(),
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
                                  questionId:
                                      _itemController.rxIbQuestion.value.id,
                                  lastSnap: _itemController.lastCommentSnap,
                                  itemController: _itemController),
                              tag: _itemController.rxIbQuestion.value.id)));
                        },
                  icon: FaIcon(
                    FontAwesomeIcons.comments,
                    color: _itemController.commented.isTrue
                        ? IbColors.accentColor
                        : Colors.grey,
                    size: 16,
                  ),
                  label: Text(
                    IbUtils.statsShortString(
                        _itemController.rxIbQuestion.value.comments),
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
                    ? IbColors.errorRed
                    : IbColors.lightGrey,
                size: 16,
              ),
              label: Text(
                _itemController.rxIbQuestion.value.likes.toString(),
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
    if (_itemController.rxIbQuestion.value.pollSize == 0) {
      return;
    }
    if (_itemController.voted.isFalse) {
      IbUtils.showSimpleSnackBar(
          msg: 'You need to answer the poll in order to see the result.',
          backgroundColor: IbColors.primaryColor);
      return;
    }

    Get.to(() => QuestionResultMainPage(_itemController));
  }
}
