import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/ib_pic_question_card.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';

class ReviewQuestionPage extends StatelessWidget {
  final IbQuestionItemController itemController;
  const ReviewQuestionPage({Key? key, required this.itemController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review your question'),
        actions: [
          Obx(() => TextButton(
                onPressed: () async {
                  await itemController.onSubmit();
                },
                child: Text(
                    itemController.isAnswering.isTrue
                        ? 'submitting'.tr
                        : 'submit'.tr,
                    style: const TextStyle(fontSize: IbConfig.kNormalTextSize)),
              )),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _handleQuestionType(),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Options',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
              ),
              ListTile(
                tileColor: Theme.of(context).primaryColor,
                leading: const Icon(
                  Icons.hourglass_top_outlined,
                  color: Colors.redAccent,
                ),
                onTap: () {
                  _timeLimitBtmSheet();
                },
                title: const Text('Time Limit'),
                trailing: Obx(() {
                  if (itemController.rxIbQuestion.value.endTimeInMs == -1) {
                    return const Text('No Time Limit');
                  }
                  return Text(IbUtils.leftTimeString(
                      itemController.rxIbQuestion.value.endTimeInMs));
                }),
              ),
              Obx(
                () => SwitchListTile(
                  tileColor: Theme.of(context).primaryColor,
                  value: itemController.rxIbQuestion.value.isCommentEnabled,
                  onChanged: (value) {
                    itemController.rxIbQuestion.value.isCommentEnabled = value;
                    itemController.rxIbQuestion.refresh();
                  },
                  title: const Text('Comment'),
                  secondary: const Icon(
                    FontAwesomeIcons.comment,
                    color: IbColors.primaryColor,
                  ),
                ),
              ),
              ListTile(
                tileColor: Theme.of(context).primaryColor,
                trailing: const Text('ALL'),
                title: const Text(
                  'Privacy Bonds',
                ),
                leading: const Icon(
                  Icons.remove_red_eye,
                  color: IbColors.primaryColor,
                ),
              ),
              Obx(
                () => SwitchListTile(
                  tileColor: Theme.of(context).primaryColor,
                  value: itemController.rxIbQuestion.value.isAnonymous,
                  onChanged: (value) {
                    itemController.rxIbQuestion.value.isAnonymous = value;
                    itemController.rxIbQuestion.refresh();
                  },
                  title: const Text('Anonymous'),
                  secondary: const Icon(
                    Icons.person,
                    color: IbColors.lightGrey,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _handleQuestionType() {
    if (itemController.rxIbQuestion.value.questionType ==
            IbQuestion.kMultipleChoice ||
        itemController.rxIbQuestion.value.questionType ==
            IbQuestion.kMultipleChoicePic) {
      return IbMcQuestionCard(itemController);
    }
    if (itemController.rxIbQuestion.value.questionType == IbQuestion.kPic) {
      return IbPicQuestionCard(itemController);
    }
    return IbScQuestionCard(
      itemController,
    );
  }

  void _timeLimitBtmSheet() {
    Get.bottomSheet(IbCard(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(
              Icons.loop_outlined,
              color: IbColors.accentColor,
            ),
            title: const Text('No Time Limit'),
            onTap: () {
              itemController.rxIbQuestion.value.endTimeInMs = -1;
              itemController.rxIbQuestion.refresh();
              Get.back();
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_today,
              color: IbColors.primaryColor,
            ),
            title: const Text('Pick a date and time'),
            onTap: () {
              Get.back();
              _showDateTimePicker();
            },
          )
        ],
      ),
    ));
  }

  void _showDateTimePicker() {
    itemController.rxIbQuestion.value.endTimeInMs =
        DateTime.now().add(const Duration(hours: 24)).millisecondsSinceEpoch;
    Get.bottomSheet(IbCard(
        child: SingleChildScrollView(
      child: Column(
        children: [
          Obx(
            () => Center(
              child: Text(
                '${DateTime.fromMillisecondsSinceEpoch(itemController.rxIbQuestion.value.endTimeInMs).year}',
                style: const TextStyle(fontSize: IbConfig.kPageTitleSize),
              ),
            ),
          ),
          SizedBox(
            height: 300,
            child: CupertinoDatePicker(
              maximumDate: DateTime.now().add(const Duration(days: 365)),
              maximumYear: 1,
              onDateTimeChanged: (value) async {
                await HapticFeedback.vibrate();
                itemController.rxIbQuestion.value.endTimeInMs =
                    value.millisecondsSinceEpoch;
                itemController.rxIbQuestion.refresh();
              },
              initialDateTime: DateTime.now().add(const Duration(hours: 24)),
              minimumDate: DateTime.now().add(const Duration(hours: 1)),
              dateOrder: DatePickerDateOrder.ymd,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Get.back();
                },
                child: const Text('Confirm'),
              )
            ],
          )
        ],
      ),
    )));
  }
}
