import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';

import '../../../backend/controllers/user_controllers/create_question_controller.dart';
import '../../ib_colors.dart';
import '../../ib_config.dart';
import '../../ib_utils.dart';

class CreateQuestionMcTab extends StatelessWidget {
  final CreateQuestionController _controller;

  const CreateQuestionMcTab(this._controller);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          _controller.swapIndex(oldIndex, newIndex);
        },
        header: headerWidget(),
        children: _controller.choiceList
            .map((element) => itemWidget(context: context, item: element))
            .toList(),
      ),
    );
  }

  Widget headerWidget() {
    return Stack(
      children: [
        IbCard(
          elevation: 0,
          radius: 8,
          child: SizedBox(
            height: IbConfig.kMcTxtItemSize,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'tap_to_add'.tr,
                    style: const TextStyle(color: IbColors.lightGrey),
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.add),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ),
        Positioned.fill(
            child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8))),
            onTap: () {
              _showBottomSheet(strTrKey: 'add_choice');
            },
          ),
        ))
      ],
    );
  }

  Widget itemWidget({required BuildContext context, required IbChoice item}) {
    return IbCard(
      key: ValueKey(item.choiceId),
      elevation: 0,
      radius: 8,
      child: SizedBox(
        height: IbConfig.kMcTxtItemSize,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  _showBottomSheet(
                      strTrKey: 'edit_choice',
                      index: _controller.choiceList.indexOf(item));
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(item.content!),
                ),
              ),
            ),
            IconButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                _controller.choiceList.remove(item);
              },
              icon: const Icon(
                Icons.remove,
                color: IbColors.errorRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOnChoiceSubmit({required String value, int? index}) {
    if (value.trim().isEmpty) {
      return;
    }

    if (_controller.isChoiceDuplicated(value.trim())) {
      Get.back();
      return;
    }

    if (index != null) {
      _controller.choiceList[index].content = value.trim();
    } else {
      _controller.choiceList.add(IbChoice(
        choiceId: IbUtils.getUniqueId(),
        content: value.trim(),
      ));
    }
    Get.back();
  }

  void _showBottomSheet({required String strTrKey, int? index}) {
    IbUtils.hideKeyboard();
    final TextEditingController _txtController = TextEditingController();
    if (index != null) {
      _txtController.text = _controller.choiceList[index].content.toString();
    }
    final Widget _widget = IbDialog(
      title: strTrKey.tr,
      content: TextField(
        textInputAction: TextInputAction.done,
        maxLength: _controller.questionType == IbQuestion.kScale
            ? IbConfig.kScAnswerMaxLength
            : IbConfig.kAnswerMaxLength,
        onSubmitted: (value) {
          _handleOnChoiceSubmit(value: value.trim(), index: index);
        },
        controller: _txtController,
        autofocus: true,
        textAlign: TextAlign.center,
        cursorColor: IbColors.primaryColor,
      ),
      onPositiveTap: () => _handleOnChoiceSubmit(
          value: _txtController.text.trim(), index: index),
      subtitle: '',
    );
    Get.bottomSheet(_widget, persistent: true, ignoreSafeArea: false);
  }
}
