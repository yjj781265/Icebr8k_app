import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_create_question_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../ib_colors.dart';

class TagPage extends StatelessWidget {
  final IbCreateQuestionController _controller;
  final TextEditingController _editingController = TextEditingController();

  TagPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              Get.back();
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                'Confirm',
                style: TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
          ],
          title: Obx(
              () => Text('Picked ${_controller.pickedTags.length}/8 Tags'))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Obx(
            () => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Picked Tags',
                        style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                      if (_controller.pickedTags.length < 8)
                        TextButton(
                            onPressed: () {
                              if (_controller.pickedTags.length < 8) {
                                showCreateTagBtmSheet();
                              }
                            },
                            child: const Text(
                              '+ New Tag',
                              style:
                                  TextStyle(fontSize: IbConfig.kNormalTextSize),
                            )),
                    ],
                  ),
                ),
                Obx(
                  () => Wrap(
                    children: _controller.pickedTags
                        .map((e) => Padding(
                              padding: const EdgeInsets.all(3),
                              child: Chip(
                                label: Text(
                                  e,
                                ),
                                backgroundColor: Theme.of(context).primaryColor,
                                onDeleted: () {
                                  _controller.pickedTags.remove(e);
                                  final int index = _controller.ibTagModels
                                      .indexWhere(
                                          (element) => element.tag.text == e);
                                  if (index != -1) {
                                    _controller.ibTagModels[index].selected =
                                        false;
                                    _controller.ibTagModels.refresh();
                                  }
                                },
                                deleteIcon: const Icon(
                                  Icons.highlight_remove,
                                  color: IbColors.lightGrey,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 2,
                ),
                if (_controller.pickedTags.length < 8)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Trending Tags',
                        style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                      IconButton(
                          onPressed: () {}, icon: const Icon(Icons.search)),
                    ],
                  ),
                if (_controller.pickedTags.length < 8)
                  Obx(
                    () => Wrap(
                      children: _controller.ibTagModels
                          .map((e) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4.0),
                                child: FilterChip(
                                  label: Text(
                                    e.tag.text,
                                  ),
                                  selected: e.selected,
                                  selectedColor: IbColors.primaryColor,
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  onSelected: (bool value) {
                                    e.selected = value;
                                    _controller.ibTagModels.refresh();
                                    if (value) {
                                      _controller.pickedTags.add(e.tag.text);
                                    } else {
                                      _controller.pickedTags.removeWhere(
                                          (element) => element == e.tag.text);
                                    }
                                  },
                                ),
                              ))
                          .toList(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showCreateTagBtmSheet() {
    _editingController.clear();
    Get.bottomSheet(SizedBox(
      height: 200,
      child: IbCard(
          child: Column(
        children: [
          Center(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onSubmitted: (value) {
                if (value.trim().isNotEmpty &&
                    !_controller.pickedTags.contains(value.trim())) {
                  _controller.pickedTags.add(value.trim());
                }
                Get.back();
              },
              controller: _editingController,
              autofocus: true,
              decoration: const InputDecoration(
                  hintText: 'Type a tag here',
                  icon: Icon(FontAwesomeIcons.tag)),
              maxLength: 30,
            ),
          )),
          SizedBox(
              width: double.infinity,
              child: TextButton(
                  onPressed: () {
                    if (_editingController.text.trim().isNotEmpty &&
                        !_controller.pickedTags
                            .contains(_editingController.text.trim())) {
                      _controller.pickedTags
                          .add(_editingController.text.trim());
                    }
                    Get.back();
                  },
                  child: Text('add'.tr)))
        ],
      )),
    ));
  }
}
