import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:reorderables/reorderables.dart';

import '../../../backend/controllers/user_controllers/create_question_tag_picker_controller.dart';

class CreateQuestionTagPicker extends StatelessWidget {
  final CreateQuestionTagPickerController _controller;

  const CreateQuestionTagPicker(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 8,
              child: Container(
                alignment: Alignment.center,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
                child: TextField(
                  onSubmitted: (value) async {
                    //TODO use typesense for full text search
                  },
                  textInputAction: TextInputAction.search,
                  controller: _controller.textEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    suffixIcon: IconButton(
                        onPressed: () {
                          _controller.textEditingController.clear();
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: IbColors.lightGrey,
                        )),
                    hintText: '🔍 Search Tags',
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                //await _controller.search();
              },
              child: const Text(
                'Search',
                style: TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            pickedTags(context),
            const Divider(
              height: 1,
              thickness: 1,
              color: IbColors.lightGrey,
            ),
            trendingTags(context),
          ],
        ),
      ),
    );
  }

  Widget pickedTags(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${'picked_tags'.tr} '
              '(${_controller.createQuestionController.pickedTags.length}'
              '/${IbConfig.kMaxTag})',
              style: const TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          ReorderableWrap(
            spacing: 4,
            onReorder: (oldIndex, newIndex) {},
            buildDraggableFeedback: (context, axis, item) {
              return Material(color: Colors.transparent, child: item);
            },
            footer: _controller.createQuestionController.pickedTags.length <
                    IbConfig.kMaxTag
                ? InkWell(
                    onTap: () {
                      showAddTagBtmSheet();
                    },
                    child: Chip(
                      label: Text(
                        'add_tag'.tr,
                      ),
                      onDeleted: () {
                        showAddTagBtmSheet();
                      },
                      deleteIcon: const Icon(
                        Icons.add,
                      ),
                    ),
                  )
                : null,
            children: _controller.createQuestionController.pickedTags
                .map((element) => Chip(
                      backgroundColor: Theme.of(context).backgroundColor,
                      label: Text(element.text),
                      onDeleted: () {
                        _controller.createQuestionController.pickedTags
                            .remove(element);
                      },
                      deleteIcon: const Icon(
                        Icons.remove_circle_outlined,
                        color: IbColors.errorRed,
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget trendingTags(BuildContext context) {
    return Obx(
      () => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'trending_tags'.tr,
              style: const TextStyle(
                  fontSize: IbConfig.kPageTitleSize,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Wrap(
              spacing: 4,
              children: _controller.trendingTags
                  .map((element) => FilterChip(
                        backgroundColor: Theme.of(context).backgroundColor,
                        label: Text(element.text),
                        selectedColor: IbColors.accentColor,
                        selected: _controller
                            .createQuestionController.pickedTags
                            .contains(element),
                        onSelected: (bool value) {
                          if (value) {
                            if (_controller.createQuestionController.pickedTags
                                    .length >=
                                IbConfig.kMaxTag) {
                              IbUtils.showSimpleSnackBar(
                                  msg: 'max_tag_info'.tr,
                                  backgroundColor: IbColors.primaryColor);
                              return;
                            }
                            _controller.createQuestionController.pickedTags
                                .add(element);
                          } else {
                            _controller.createQuestionController.pickedTags
                                .remove(element);
                          }
                        },
                      ))
                  .toList()),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () async {
                await _controller.loadMore();
              },
              child: Text(_controller.footerText.value),
            ),
          )
        ],
      ),
    );
  }

  void showAddTagBtmSheet() {
    final TextEditingController controller = TextEditingController();
    final TextField textField = TextField(
      autofocus: true,
      decoration: InputDecoration(hintText: 'tag_picker_dialog_hint'.tr),
      maxLength: 30,
      textInputAction: TextInputAction.done,
      controller: controller,
    );
    final dialog = IbDialog(
      title: 'tag_picker_dialog_title'.tr,
      subtitle: '',
      onPositiveTap: () {
        Get.back();
        _controller.addNewTag(controller.text);
      },
      content: textField,
    );
    Get.bottomSheet(dialog);
  }
}
