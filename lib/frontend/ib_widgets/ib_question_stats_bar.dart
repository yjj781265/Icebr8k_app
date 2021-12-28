import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

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
                    onTap: _itemController.isSample ? null : () {},
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
                      onTap: _itemController.isSample ? null : () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: Row(
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.comment,
                              color: IbColors.lightGrey,
                              size: 19,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              _statsShortString(_itemController.comments.value),
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

  String _statsShortString(int number) {
    if (number < 1000) {
      return number.toString();
    }

    if (number >= 1000 && number < 999999) {
      final double num = number.toDouble() / 1000;
      return '${num.toStringAsFixed(1)}K';
    }

    if (number >= 999999 && number < 9999999) {
      final double num = number.toDouble() / 1000000;
      return '${num.toStringAsFixed(1)}M';
    }

    if (number >= 9999999 && number < 9999999999) {
      final double num = number.toDouble() / 10000000;
      return '${num.toStringAsFixed(1)}B';
    }

    return '10B+';
  }
}
