import 'dart:io';

import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_create_question_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

import '../ib_config.dart';

class CreateQuestionPage extends StatefulWidget {
  const CreateQuestionPage({Key? key}) : super(key: key);

  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage>
    with SingleTickerProviderStateMixin {
  final IbCreateQuestionController _controller =
      Get.put(IbCreateQuestionController());
  final TextEditingController _questionEditingController =
      TextEditingController();
  final TextEditingController _descriptionEditingController =
      TextEditingController();
  final TextEditingController _customTagController = TextEditingController();
  late TabController _tabController;
  late List<Widget> chips;

  @override
  void initState() {
    super.initState();
    _controller.questionEditController = _questionEditingController;
    _controller.descriptionEditController = _descriptionEditingController;
    _tabController = TabController(vsync: this, length: 4);
    _tabController.addListener(() {
      if (_tabController.index == 0) {
        _controller.questionType = IbQuestion.kMultipleChoice;
        _controller.title.value = 'text only';
      } else if (_tabController.index == 1) {
        _controller.questionType = IbQuestion.kMultipleChoicePic;
        _controller.title.value = 'text with picture';
      } else if (_tabController.index == 2) {
        _controller.questionType = IbQuestion.kPic;
        _controller.title.value = 'picture only';
      } else {
        _controller.questionType = IbQuestion.kScale;
        _controller.title.value = 'scale';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            'create_question'.trParams({'type': _controller.title.value}),
            style: const TextStyle(fontSize: IbConfig.kPageTitleSize),
          ),
        ),
        actions: [
          IconButton(
              onPressed: () {
                _controller.validQuestion();
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: ExtendedNestedScrollView(
        onlyOneScrollInBody: true,
        dragStartBehavior: DragStartBehavior.down,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: SizedBox(
                height: 150,
                child: IbCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      onChanged: (question) {
                        _controller.question = question;
                      },
                      keyboardType: TextInputType.text,
                      controller: _questionEditingController,
                      minLines: 3,
                      maxLines: 8,
                      maxLength: IbConfig.kQuestionTitleMaxLength,
                      style: const TextStyle(
                          fontSize: IbConfig.kPageTitleSize,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'question'.tr,
                          hintStyle: const TextStyle(
                            color: IbColors.lightGrey,
                          )),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 120,
                child: IbCard(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextField(
                      maxLines: 8,
                      keyboardType: TextInputType.multiline,
                      onChanged: (description) {
                        _controller.description = description;
                      },
                      controller: _descriptionEditingController,
                      style: const TextStyle(
                        fontSize: IbConfig.kSecondaryTextSize,
                      ),
                      maxLength: IbConfig.kQuestionDescMaxLength,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintStyle: const TextStyle(color: IbColors.lightGrey),
                        hintText: 'description_option'.tr,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: Wrap(
                      children: [
                        Obx(
                          () => ReorderableWrap(
                            onReorder: (int oldIndex, int newIndex) {
                              final String tag =
                                  _controller.pickedTags.removeAt(oldIndex);
                              _controller.pickedTags.insert(newIndex, tag);
                            },
                            buildDraggableFeedback: (context, axis, item) {
                              return Material(
                                color: Colors.transparent,
                                child: item,
                              );
                            },
                            controller: ScrollController(),
                            children: _controller.pickedTags
                                .map((e) => Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4.0),
                                      child: Chip(
                                        label: Text(
                                          e,
                                        ),
                                        backgroundColor:
                                            Theme.of(context).primaryColor,
                                        onDeleted: () {
                                          _controller.pickedTags.remove(e);
                                          final int index = _controller
                                              .ibTagCheckBoxModels
                                              .indexWhere((element) =>
                                                  element.tag == e);
                                          if (index != -1) {
                                            _controller
                                                .ibTagCheckBoxModels[index]
                                                .selected
                                                .value = false;
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
                        Obx(() {
                          if (_controller.pickedTags.length < 8) {
                            return Chip(
                              backgroundColor: Theme.of(context).primaryColor,
                              label: const Text(
                                'Add a tag 🏷️',
                                style: TextStyle(color: IbColors.lightGrey),
                              ),
                              deleteIcon: const Tooltip(
                                message: 'Add a tag',
                                child: Icon(Icons.add_circle_outline),
                              ),
                              onDeleted: () {
                                _customTagController.clear();
                                _controller.isCustomTagSelected.value = false;
                                _showTagsBottomSheet();
                              },
                            );
                          }
                          return const SizedBox();
                        }),
                      ],
                    )),
              ),
            ),
            SliverOverlapAbsorber(
              handle: ExtendedNestedScrollView.sliverOverlapAbsorberHandleFor(
                  context),
              sliver: SliverPersistentHeader(
                pinned: true,
                delegate: PersistentHeader(
                  widget: IbCard(
                    child: TabBar(
                      controller: _tabController,
                      tabs: [
                        Tooltip(
                            message: 'mc'.tr,
                            child: const Tab(
                                icon: Icon(
                              FontAwesomeIcons.bars,
                            ))),
                        Tooltip(
                            message: 'mc_p'.tr,
                            child:
                                const Tab(icon: Icon(FontAwesomeIcons.listUl))),
                        Tooltip(
                            message: 'pic'.tr,
                            child: const Tab(
                                icon: Icon(FontAwesomeIcons.thLarge))),
                        Tooltip(
                            message: 'sc'.tr,
                            child: const Tab(
                                icon: Icon(FontAwesomeIcons.slidersH))),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ];
        },
        body: Padding(
          padding: const EdgeInsets.only(top: 56),
          child: TabBarView(
            controller: _tabController,
            children: [
              _mCTab(),
              _mCWithPicTab(),
              _picTab(),
              _sCTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mCTab() {
    return SingleChildScrollView(
      physics: const PageScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () {
                if (_controller.choiceList.length < IbConfig.kChoiceLimit) {
                  _showTextFiledBottomSheet(
                      'add_choice', _controller.choiceList);
                } else {
                  IbUtils.showSimpleSnackBar(
                      msg: 'choice_limit'.tr,
                      backgroundColor: IbColors.errorRed);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                width: Get.width * 0.95,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'tap_to_add'.tr,
                      style: const TextStyle(color: IbColors.lightGrey),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.add_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Obx(() => ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  print('$oldIndex to $newIndex');
                  _controller.swapIndex(oldIndex, newIndex);
                },
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                primary: false,
                children: [
                  for (final item in _controller.choiceList)
                    GestureDetector(
                      key: UniqueKey(),
                      onTap: () {
                        _showEditTextFiledBtmSheet(item);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.all(8),
                        height: 46,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).primaryColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item.content!),
                            IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _controller.choiceList.remove(item);
                                },
                                icon: const Icon(
                                  Icons.remove,
                                  color: IbColors.errorRed,
                                ))
                          ],
                        ),
                      ),
                    )
                ],
              ))
        ],
      ),
    );
  }

  Widget _picTab() {
    return AnimatedSize(
        duration: const Duration(milliseconds: 300),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          children: [
            Obx(() {
              if (_controller.picList.length < 8) {
                return GestureDetector(
                  onTap: () {
                    showMediaBottomSheet(context, null, _controller.picList);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                          color: IbColors.lightGrey,
                          borderRadius: BorderRadius.circular(8)),
                      width: Get.width / 4,
                      height: Get.width / 4,
                      child: const Icon(Icons.add),
                    ),
                  ),
                );
              }
              return const SizedBox();
            }),
            Obx(
              () => ReorderableWrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                runAlignment: WrapAlignment.center,
                onReorder: (int oldIndex, int newIndex) {
                  final IbChoice ibChoice =
                      _controller.picList.removeAt(oldIndex);
                  _controller.picList.insert(newIndex, ibChoice);
                },
                buildDraggableFeedback: (context, axis, item) {
                  return Material(
                    color: Colors.transparent,
                    child: item,
                  );
                },
                controller: ScrollController(),
                children: _controller.picList
                    .map(
                      (e) => Stack(
                        children: [
                          GestureDetector(
                            onTap: () {
                              showMediaBottomSheet(
                                  context, e, _controller.picList);
                            },
                            child: IbCard(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(e.url!),
                                    width: Get.width / 4,
                                    height: Get.width / 4,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -14,
                            top: -14,
                            child: IconButton(
                              color: IbColors.errorRed.withOpacity(1.0),
                              onPressed: () {
                                _controller.picList.remove(e);
                              },
                              icon: const Icon(Icons.remove_circle),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ));
  }

  Widget _mCWithPicTab() {
    return SingleChildScrollView(
      physics: const PageScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () {
                if (_controller.picChoiceList.length < IbConfig.kChoiceLimit) {
                  _showTextFiledBottomSheet(
                      'add_choice', _controller.picChoiceList);
                } else {
                  IbUtils.showSimpleSnackBar(
                      msg: 'choice_limit'.tr,
                      backgroundColor: IbColors.errorRed);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                width: Get.width * 0.95,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).primaryColor,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        showMediaBottomSheet(
                            context, null, _controller.picChoiceList);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: IbColors.lightGrey,
                        ),
                        width: 56,
                        height: 56,
                        child: const Icon(Icons.add),
                      ),
                    ),
                    Text(
                      'tap_to_add'.tr,
                      style: const TextStyle(color: IbColors.lightGrey),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Icon(Icons.add_outlined),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Obx(() => ReorderableListView(
                onReorder: (oldIndex, newIndex) {
                  print('$oldIndex to $newIndex');
                  _controller.swapIndex(oldIndex, newIndex);
                },
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                primary: false,
                children: [
                  for (final item in _controller.picChoiceList)
                    GestureDetector(
                      key: UniqueKey(),
                      onTap: () {
                        _showEditTextFiledBtmSheet(item);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        padding: const EdgeInsets.all(8),
                        height: 72,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Theme.of(context).primaryColor),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (item.url != null && item.url!.isNotEmpty)
                              GestureDetector(
                                onTap: () {
                                  showMediaBottomSheet(
                                      context, item, _controller.picChoiceList);
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    File(item.url!),
                                    width: 56,
                                    height: 56,
                                  ),
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: () {
                                  showMediaBottomSheet(
                                      context, item, _controller.picChoiceList);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: IbColors.lightGrey,
                                  ),
                                  width: 56,
                                  height: 56,
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            if (item.content != null &&
                                item.content!.isNotEmpty)
                              Text(item.content!)
                            else
                              const Text(
                                'Add text here',
                                style: TextStyle(color: IbColors.lightGrey),
                              ),
                            IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  _controller.picChoiceList.remove(item);
                                },
                                icon: const Icon(
                                  Icons.remove,
                                  color: IbColors.errorRed,
                                ))
                          ],
                        ),
                      ),
                    )
                ],
              ))
        ],
      ),
    );
  }

  Widget _sCTab() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_controller.scaleEndPoints.length <
                    IbConfig.kScChoiceLimit) {
                  _showTextFiledBottomSheet(
                      'add_endpoint', _controller.scaleEndPoints);
                } else {
                  IbUtils.showSimpleSnackBar(
                      msg: 'choice_limit_sc'.tr,
                      backgroundColor: IbColors.errorRed);
                }
              },
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(8),
                height: 46,
                decoration: BoxDecoration(
                    color: IbColors.white,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'tap_to_add_sc'.tr,
                      style: const TextStyle(color: IbColors.lightGrey),
                    ),
                    const Icon(Icons.add_outlined),
                  ],
                ),
              ),
            ),
          ),
          Obx(
            () => ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                print('$oldIndex to $newIndex');
                _controller.swapIndex(oldIndex, newIndex);
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              primary: false,
              children: [
                for (final item in _controller.scaleEndPoints)
                  IbCard(
                    key: UniqueKey(),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      padding: const EdgeInsets.all(8),
                      height: 46,
                      decoration:
                          BoxDecoration(borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(item.content!),
                          IconButton(
                              onPressed: () {
                                _controller.scaleEndPoints.remove(item);
                              },
                              icon: const Icon(
                                Icons.delete_outlined,
                                color: IbColors.errorRed,
                              ))
                        ],
                      ),
                    ),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showTextFiledBottomSheet(String strTrKey, List<IbChoice> list) {
    final TextEditingController _txtController = TextEditingController();
    final IbChoice ibChoice =
        IbChoice(choiceId: IbUtils.getUniqueId(), content: '', url: '');
    final Widget _widget = IbCard(
        child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strTrKey.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: IbConfig.kPageTitleSize,
            ),
          ),
          TextField(
            textInputAction: TextInputAction.done,
            maxLength: _controller.questionType == IbQuestion.kScale
                ? IbConfig.kScAnswerMaxLength
                : IbConfig.kAnswerMaxLength,
            onSubmitted: (value) {
              ibChoice.content = value.trim();
              if (ibChoice.content!.isEmpty) {
                return;
              }

              if (_controller.isChoiceDuplicated(ibChoice.content!)) {
                Get.back();
                return;
              }

              list.add(ibChoice);
              Get.back();
            },
            controller: _txtController,
            autofocus: true,
            textAlign: TextAlign.center,
            cursorColor: IbColors.primaryColor,
          ),
          TextButton(
            onPressed: () {
              ibChoice.content = _txtController.text.trim();
              if (ibChoice.content!.isEmpty) {
                return;
              }
              if (_controller.isChoiceDuplicated(ibChoice.content!)) {
                Get.back();
                return;
              }
              list.add(ibChoice);
              Get.back();
            },
            child: Text('add'.tr),
          ),
        ],
      ),
    ));
    Get.bottomSheet(
      SizedBox(height: 200, child: _widget),
      persistent: true,
    );
  }

  void _showTagsBottomSheet() {
    final Widget tagsBtmSheet = IbCard(
        child: Obx(
      () => Column(
        children: [
          Flexible(
            child: Row(
              children: [
                Flexible(
                  flex: 16,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      maxLength: 30,
                      controller: _customTagController,
                      decoration: const InputDecoration(
                        hintText: 'Add a Custom Tag',
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Checkbox(
                      onChanged: (bool? value) {
                        if (value! && _controller.pickedTags.length >= 8) {
                          IbUtils.showSimpleSnackBar(
                              msg: '8 Tags Max',
                              backgroundColor: IbColors.errorRed);
                          return;
                        }

                        final text = _customTagController.text.trim();

                        if (value && text.isEmpty) {
                          IbUtils.showSimpleSnackBar(
                              msg: 'Custom Tag is Empty',
                              backgroundColor: IbColors.errorRed);
                          return;
                        }

                        _controller.isCustomTagSelected.value = value;

                        if (value && text.isNotEmpty) {
                          _controller.pickedTags.add(text);

                          // un focus text field
                          final FocusScopeNode currentFocus =
                              FocusScope.of(context);

                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }

                          IbUtils.hideKeyboard();
                        } else {
                          final int index = _controller.pickedTags
                              .indexWhere((element) => element == text);
                          if (index != -1) {
                            _controller.pickedTags.removeAt(index);
                          }
                        }
                      },
                      value: _controller.isCustomTagSelected.value,
                    ),
                  ),
                )
              ],
            ),
          ),
          Flexible(
            flex: 6,
            child: Scrollbar(
              isAlwaysShown: true,
              child: ListView(
                children: _controller.ibTagCheckBoxModels
                    .map((e) => CheckboxListTile(
                          value: e.selected.value,
                          onChanged: (value) {
                            if (value! && _controller.pickedTags.length >= 8) {
                              IbUtils.showSimpleSnackBar(
                                  msg: '8 Tags Max',
                                  backgroundColor: IbColors.errorRed);
                              return;
                            }

                            e.selected.value = value;

                            if (value && _controller.pickedTags.length <= 8) {
                              _controller.pickedTags.add(e.tag);
                            } else {
                              _controller.pickedTags.remove(e.tag);
                            }
                          },
                          title: Text(e.tag),
                        ))
                    .toList(),
              ),
            ),
          ),
          Flexible(
              child: SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {
                setState(() {
                  if (_controller.pickedTags.length <= 8) {
                    Get.back();
                    return;
                  }
                });
              },
              child: Text(
                'Added ${_controller.pickedTags.length}/8 tags',
              ),
            ),
          )),
        ],
      ),
    ));
    Get.bottomSheet(
      SizedBox(height: Get.height * 0.6, child: tagsBtmSheet),
      isScrollControlled: true,
      persistent: true,
    );
  }

  void _showEditTextFiledBtmSheet(IbChoice ibChoice) {
    final TextEditingController _txtController = TextEditingController();
    _txtController.text = ibChoice.content == null ? '' : ibChoice.content!;

    final Widget _widget = IbCard(
        child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Edit a choice',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: IbConfig.kPageTitleSize,
            ),
          ),
          TextField(
            textInputAction: TextInputAction.done,
            maxLength: _controller.questionType == IbQuestion.kScale
                ? IbConfig.kScAnswerMaxLength
                : IbConfig.kAnswerMaxLength,
            onSubmitted: (value) {
              if (_controller.questionType == IbQuestion.kMultipleChoice &&
                  _controller.isChoiceDuplicated(value.trim())) {
                Get.back();
                return;
              }

              if (_controller.questionType == IbQuestion.kScale &&
                  _controller.isChoiceDuplicated(value.trim())) {
                Get.back();
                return;
              }

              setState(() {
                ibChoice.content = value.trim();
                Get.back();
              });
            },
            controller: _txtController,
            autofocus: true,
            textAlign: TextAlign.center,
            cursorColor: IbColors.primaryColor,
          ),
          TextButton(
            onPressed: () {
              if (_controller.questionType == IbQuestion.kMultipleChoice &&
                  _controller.isChoiceDuplicated(_txtController.text.trim())) {
                Get.back();
                return;
              }

              if (_controller.questionType == IbQuestion.kScale &&
                  _controller.isChoiceDuplicated(_txtController.text.trim())) {
                Get.back();
                return;
              }

              setState(() {
                ibChoice.content = _txtController.text.trim();
                Get.back();
              });
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    ));
    Get.bottomSheet(
      SizedBox(height: 200, child: _widget),
      persistent: true,
    );
  }
}

void showMediaBottomSheet(
    BuildContext context, IbChoice? ibChoice, RxList<IbChoice> list) {
  final Widget options = ListView(
    shrinkWrap: true,
    children: [
      InkWell(
        onTap: () async {
          Get.back();
          final _picker = ImagePicker();
          final XFile? pickedFile = await _picker.pickImage(
            source: ImageSource.camera,
            imageQuality: IbConfig.kImageQuality,
          );

          if (pickedFile != null) {
            final File? croppedFile = await IbUtils.showImageCropper(
                pickedFile.path,
                cropStyle: CropStyle.rectangle,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true,
                minimumAspectRatio: 1,
                ratios: [CropAspectRatioPreset.square]);
            if (croppedFile != null) {
              if (ibChoice != null) {
                // ignore: parameter_assignments
                ibChoice!.url = croppedFile.path;
              } else {
                // ignore: parameter_assignments
                ibChoice = IbChoice(
                    choiceId: IbUtils.getUniqueId(), url: croppedFile.path);
                // ignore: parameter_assignments
                list.add(ibChoice!);
              }

              list.refresh();
            }
          }
        },
        child: Ink(
          height: 56,
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const [
                Icon(
                  Icons.camera_alt_outlined,
                  color: IbColors.primaryColor,
                ),
                SizedBox(
                  width: 8,
                ),
                Text('Take a photo',
                    style: TextStyle(fontSize: IbConfig.kNormalTextSize)),
              ],
            ),
          ),
        ),
      ),
      InkWell(
        onTap: () async {
          Get.back();
          final _picker = ImagePicker();
          final XFile? pickedFile = await _picker.pickImage(
            source: ImageSource.gallery,
            imageQuality: IbConfig.kImageQuality,
          );

          if (pickedFile != null) {
            final File? croppedFile = await IbUtils.showImageCropper(
              pickedFile.path,
              cropStyle: CropStyle.rectangle,
              ratios: [CropAspectRatioPreset.square],
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: true,
              minimumAspectRatio: 1,
            );

            if (croppedFile != null) {
              if (ibChoice != null) {
                // ignore: parameter_assignments
                ibChoice!.url = croppedFile.path;
              } else {
                // ignore: parameter_assignments
                ibChoice = IbChoice(
                  choiceId: IbUtils.getUniqueId(),
                  url: croppedFile.path,
                );
                // ignore: parameter_assignments
                list.add(ibChoice!);
              }
              list.refresh();
            }
          }
        },
        child: Ink(
          height: 56,
          width: double.infinity,
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: const [
                Icon(
                  Icons.photo_album_outlined,
                  color: IbColors.errorRed,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Choose from gallery',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Get.bottomSheet(SafeArea(child: options));
}
