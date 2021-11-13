import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

import '../ib_config.dart';

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Obx(
                () => InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      FaIcon(
                        Icons.poll_outlined,
                        color: _itemController.ibAnswer != null
                            ? IbColors.primaryColor
                            : IbColors.lightGrey,
                        size: 18,
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
              const SizedBox(
                width: 8,
              ),
              Obx(
                () => InkWell(
                  onTap: () {},
                  child: Row(
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.comment,
                        color: IbColors.lightGrey,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 3,
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
              const SizedBox(
                width: 8,
              ),
              Obx(
                () => InkWell(
                  onTap: () {
                    _itemController.updateLike();
                  },
                  child: Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.thumbsUp,
                        color: _itemController.liked.isTrue
                            ? IbColors.accentColor
                            : IbColors.lightGrey,
                        size: 16,
                      ),
                      const SizedBox(
                        width: 3,
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
