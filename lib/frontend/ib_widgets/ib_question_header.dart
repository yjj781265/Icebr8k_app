import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/create_question_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_report_controller.dart';
import 'package:icebr8k/backend/models/ib_report.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/create_question_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_report_card.dart';

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
              mainAxisSize: MainAxisSize.min,
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
              children: [
                if (_itemController.rxIbQuestion.value.isQuiz)
                  const Icon(
                    Icons.question_mark,
                    color: IbColors.accentColor,
                    size: 16,
                  ),
                IconButton(
                    onPressed: _itemController.rxIsSample.isTrue
                        ? null
                        : () async {
                            await _showMoreOptions();
                          },
                    icon: const FaIcon(
                      Icons.more_vert_outlined,
                    )),
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
          disableOnTap: _itemController.rxIsSample.isTrue,
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

  Future<void> _showMoreOptions() async {
    final options = Column(
      children: [
        if (_itemController.rxIbQuestion.value.creatorId ==
                IbUtils.getCurrentUid() &&
            _itemController.rxIbQuestion.value.pollSize == 0)
          ListTile(
            onTap: () {
              Get.back();
              Get.to(() => CreateQuestionPage(
                  controller: Get.put(CreateQuestionController(
                      itemController: _itemController))));
            },
            leading: const Icon(
              Icons.edit,
              color: IbColors.primaryColor,
            ),
            title: const Text("Edit"),
          ),
        ListTile(
          leading: const Icon(
            Icons.remove_red_eye,
            color: IbColors.primaryColor,
          ),
          title: const Text("Privacy Bound"),
          subtitle: Text(
            _itemController.rxIbQuestion.value.isPublic
                ? 'Public'
                : 'Friends Only',
            style: const TextStyle(color: IbColors.lightGrey),
          ),
        ),
        ListTile(
          onTap: () {
            Get.back();
            Get.bottomSheet(IbReportCard(
                ibReportController: Get.put(
                    IbReportController(
                        type: ReportType.poll,
                        reporteeId:
                            _itemController.rxIbQuestion.value.creatorId,
                        url: _itemController.rxIbQuestion.value.id),
                    tag: _itemController.rxIbQuestion.value.id)));
          },
          leading: const Icon(
            Icons.report,
            color: IbColors.errorRed,
          ),
          title: const Text(
            "Report",
            style: TextStyle(color: IbColors.errorRed),
          ),
        ),
        const Spacer(),
        SizedBox(
            width: double.infinity,
            child: IbElevatedButton(
                textTrKey: 'cancel',
                color: IbColors.primaryColor,
                onPressed: () {
                  Get.back();
                }))
      ],
    );
    Get.bottomSheet(Center(child: IbCard(child: options)));
  }
}
