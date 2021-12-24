import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

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
              crossAxisAlignment: CrossAxisAlignment.start,
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
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: _itemController.isSample ? null : () {},
                  icon: const FaIcon(Icons.more_vert_outlined))
            ],
          )
        ],
      ),
    );
  }

  Widget _handleAvatarImage() {
    return Obx(() {
      if (!_itemController.rxIbQuestion.value.isAnonymous) {
        return IbUserAvatar(
          disableOnTap: _itemController.disableAvatarOnTouch,
          avatarUrl: _itemController.avatarUrl.value,
          uid: _itemController.ibUser == null ? '' : _itemController.ibUser!.id,
          radius: 16,
        );
      }

      return const CircleAvatar(
        backgroundColor: IbColors.primaryColor,
        radius: 16,
        child: Text(
          'A',
          style: TextStyle(color: Colors.black),
        ),
      );
    });
  }

  Widget _handleSubString() {
    return Obx(() {
      return Text(
          '${IbUtils.getAgoDateTimeString(
            DateTime.fromMillisecondsSinceEpoch(
                _itemController.rxIbQuestion.value.askedTimeInMs),
          )} ${_itemController.rxIbQuestion.value.endTimeInMs == -1 ? '' : ' • ${IbUtils.leftTimeString(_itemController.rxIbQuestion.value.endTimeInMs)}'}',
          style: const TextStyle(
              fontSize: IbConfig.kDescriptionTextSize,
              color: IbColors.lightGrey));
    });
  }
}
