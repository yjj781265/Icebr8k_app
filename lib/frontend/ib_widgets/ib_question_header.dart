import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../backend/controllers/user_controllers/ib_question_item_controller.dart';
import '../ib_config.dart';
import 'ib_user_avatar.dart';

class IbQuestionHeader extends StatelessWidget {
  final IbQuestionItemController _itemController;
  const IbQuestionHeader(
    this._itemController,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Obx(
            () => Row(
              children: [
                _handleAvatarImage(),
                const SizedBox(
                  width: 8,
                ),
                SizedBox(
                  width: 200,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _itemController.rxIbQuestion.value.isAnonymous
                            ? 'Anonymous'
                            : _itemController.title.value,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: IbConfig.kNormalTextSize,
                            fontWeight: FontWeight.w700),
                      ),
                      _handleSubString(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Obx(
            () => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_itemController.rxIbQuestion.value.isQuiz)
                  const IconButton(
                    iconSize: 16,
                    icon: Icon(FontAwesomeIcons.question),
                    disabledColor: IbColors.accentColor,
                    onPressed: null,
                  ),
                IconButton(
                    onPressed: _itemController.isSample
                        ? null
                        : () async {
                            /*  await IbQuestionDbService().removeQuestion(
                                _itemController.rxIbQuestion.value);*/
                          },
                    icon: const FaIcon(Icons.more_vert_outlined))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _handleAvatarImage() {
    return Obx(() {
      if (!_itemController.rxIbQuestion.value.isAnonymous) {
        return IbUserAvatar(
          compScore: _itemController.compScore.value,
          disableOnTap: _itemController.isSample,
          avatarUrl: _itemController.avatarUrl.value,
          uid: _itemController.rxIbQuestion.value.creatorId,
          radius: 20,
        );
      }

      return const CircleAvatar(
        backgroundColor: IbColors.creamYellow,
        radius: 20,
        child: Icon(
          Icons.person_rounded,
          color: IbColors.lightGrey,
        ),
      );
    });
  }

  Widget _handleSubString() {
    return Obx(() {
      return Row(children: [
        Text(
          IbUtils.getAgoDateTimeString(
            DateTime.fromMillisecondsSinceEpoch(
                _itemController.rxIbQuestion.value.askedTimeInMs),
          ),
          style: const TextStyle(
              fontSize: IbConfig.kDescriptionTextSize,
              color: IbColors.lightGrey),
        ),
        if (_itemController.rxIbQuestion.value.endTimeInMs != -1)
          const Text(
            ' • ',
            style: TextStyle(color: IbColors.lightGrey),
          ),
        if (_itemController.rxIbQuestion.value.endTimeInMs != -1)
          IbUtils.leftTimeText(_itemController.rxIbQuestion.value.endTimeInMs)
      ]);
    });
  }
}
