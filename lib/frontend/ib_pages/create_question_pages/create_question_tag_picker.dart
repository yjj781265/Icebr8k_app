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
        leadingWidth: 40,
        title: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(8)),
          ),
          child: TextField(
            textInputAction: TextInputAction.search,
            controller: _controller.textEditingController,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: Obx(
                () => _controller.searchText.isEmpty
                    ? const SizedBox()
                    : IconButton(
                        onPressed: () {
                          _controller.textEditingController.clear();
                        },
                        icon: const Icon(
                          Icons.cancel,
                          color: IbColors.lightGrey,
                        )),
              ),
              hintText: 'Search Tags',
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('confirm'.tr))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              searchResultTags(context),
              pickedTags(context),
              const Divider(
                height: 1,
                thickness: 1,
              ),
              trendingTags(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget searchResultTags(BuildContext context) {
    return Obx(() {
      if (_controller.searchResults.isNotEmpty) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Search Results',
                style: TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _controller.searchResults
                    .map((element) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: FilterChip(
                            pressElevation: 0,
                            backgroundColor: Theme.of(context).backgroundColor,
                            avatar: _controller
                                    .createQuestionController.pickedTags
                                    .contains(element)
                                ? const SizedBox()
                                : const Icon(Icons.add),
                            label: Text(element.text),
                            selectedColor: IbColors.accentColor,
                            selected: _controller
                                .createQuestionController.pickedTags
                                .contains(element),
                            onSelected: (bool value) {
                              if (value) {
                                if (_controller.createQuestionController
                                        .pickedTags.length >=
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
                          ),
                        ))
                    .toList(),
              ),
            ),
            const Divider(
              height: 1,
              thickness: 1,
            )
          ],
        );
      }
      return const SizedBox();
    });
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
            onReorder: (oldIndex, newIndex) {
              final pickedTag = _controller.createQuestionController.pickedTags
                  .removeAt(oldIndex);
              _controller.createQuestionController.pickedTags
                  .insert(newIndex, pickedTag);
            },
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
                        pressElevation: 0,
                        backgroundColor: Theme.of(context).backgroundColor,
                        avatar: _controller.createQuestionController.pickedTags
                                .contains(element)
                            ? const SizedBox()
                            : const Icon(Icons.add),
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
