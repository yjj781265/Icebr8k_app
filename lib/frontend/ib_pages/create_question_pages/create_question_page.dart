import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/create_question_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/create_question_mc_tab.dart';
import 'package:icebr8k/frontend/ib_pages/ib_tenor_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../ib_config.dart';
import 'ib_media_bar.dart';

class CreateQuestionPage extends StatefulWidget {
  const CreateQuestionPage({Key? key}) : super(key: key);

  @override
  _CreateQuestionPageState createState() => _CreateQuestionPageState();
}

class _CreateQuestionPageState extends State<CreateQuestionPage>
    with SingleTickerProviderStateMixin {
  final CreateQuestionController _controller =
      Get.put(CreateQuestionController());
  late TabController _tabController;
  late List<Widget> chips;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 1);
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
    return ShowCaseWidget(
      onFinish: () {
        IbLocalDataService().updateBoolValue(
            key: StorageKey.pickTagForQuestionBool, value: true);
      },
      builder: Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            centerTitle: false,
            title: Obx(
              () => Text(
                'create_question'.trParams({'type': _controller.title.value}),
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    _controller.validQuestion(context);
                  },
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                  )),
            ],
          ),
          body: Scrollbar(
            radius: const Radius.circular(8),
            child: ExtendedNestedScrollView(
              onlyOneScrollInBody: true,
              dragStartBehavior: DragStartBehavior.down,
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: IbCard(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          children: [
                            TextField(
                              keyboardType: TextInputType.text,
                              controller: _controller.questionEditController,
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
                            const SizedBox(
                              height: 8,
                            ),
                            const Divider(
                              height: 0,
                              thickness: 1,
                            ),
                            IbMediaBar(_controller),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: IbCard(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          controller: _controller.descriptionEditController,
                          maxLengthEnforcement: MaxLengthEnforcement.enforced,
                          minLines: 3,
                          maxLines: 8,
                          maxLength: IbConfig.kQuestionDescMaxLength,
                          style: const TextStyle(
                              fontSize: IbConfig.kNormalTextSize,
                              fontWeight: FontWeight.normal),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'description_option'.tr,
                              hintStyle: const TextStyle(
                                color: IbColors.lightGrey,
                              )),
                        ),
                      ),
                    ),
                  ),
                  /*SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          child: Wrap(
                            runAlignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.end,
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
                                              elevation: 1,
                                              label: Text(
                                                e,
                                              ),
                                              backgroundColor: Theme.of(context)
                                                  .backgroundColor,
                                              onDeleted: () {
                                                _controller.pickedTags.remove(e);
                                                final int index = _controller
                                                    .ibTagModels
                                                    .indexWhere((element) =>
                                                        element.tag.text == e);
                                                if (index != -1) {
                                                  _controller.ibTagModels[index]
                                                      .selected = false;
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
                                  return TextButton.icon(
                                      onPressed: () {
                                        _customTagController.clear();
                                        _controller.isCustomTagSelected.value =
                                            false;
                                        _showTagsDialog();
                                      },
                                      icon: const Tooltip(
                                        message: 'Add Tags',
                                        child: Icon(Icons.add_circle_outline),
                                      ),
                                      label: const Text(
                                        'Add Tags 🏷️',
                                      ));
                                }
                                return const SizedBox();
                              }),
                            ],
                          )),
                    ),
                  ),*/

                  SliverOverlapAbsorber(
                    handle:
                        ExtendedNestedScrollView.sliverOverlapAbsorberHandleFor(
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
                              /*   Tooltip(
                                  message: 'mc_p'.tr,
                                  child: const Tab(
                                      icon: Icon(FontAwesomeIcons.listUl))),
                              Tooltip(
                                  message: 'pic'.tr,
                                  child: const Tab(
                                      icon: Icon(FontAwesomeIcons.square))),
                              Tooltip(
                                  message: 'sc'.tr,
                                  child: const Tab(
                                      icon: Icon(FontAwesomeIcons.slidersH))),*/
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
                    CreateQuestionMcTab(_controller),
                    /*  _mCWithPicTab(),
                    _picTab(),
                    _sCTab(),*/
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _mCWithPicTab() {
    return SingleChildScrollView(
      physics: const PageScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              customBorder: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              onTap: () {
                IbUtils.hideKeyboard();
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                width: Get.width * 0.95,
                height: IbConfig.kMcPicItemHeight,
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
                        width: IbConfig.kMcPicHeight,
                        height: IbConfig.kMcPicHeight,
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
          Obx(() => ReorderableColumn(
                onReorder: (oldIndex, newIndex) {
                  print('$oldIndex to $newIndex');
                  _controller.swapIndex(oldIndex, newIndex);
                },
                children: _controller.picChoiceList
                    .map((item) => GestureDetector(
                          key: UniqueKey(),
                          onTap: () {
                            // _showEditTextFiledBtmSheet(item);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            padding: const EdgeInsets.all(8),
                            height: IbConfig.kMcPicItemHeight,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).primaryColor),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (item.url != null && item.url!.isNotEmpty)
                                  InkWell(
                                    onTap: () {
                                      showMediaBottomSheet(context, item,
                                          _controller.picChoiceList);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: SizedBox(
                                        width: IbConfig.kMcPicHeight,
                                        height: IbConfig.kMcPicHeight,
                                        child: item.url!.contains('http')
                                            ? CachedNetworkImage(
                                                fadeInDuration: const Duration(
                                                    milliseconds: 300),
                                                fit: BoxFit.fill,
                                                imageUrl: item.url!,
                                                height: IbConfig.kPicHeight,
                                                width: IbConfig.kPicHeight,
                                              )
                                            : Image.file(
                                                File(item.url!),
                                                fit: BoxFit.fill,
                                              ),
                                      ),
                                    ),
                                  )
                                else
                                  InkWell(
                                    onTap: () {
                                      showMediaBottomSheet(context, item,
                                          _controller.picChoiceList);
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: IbColors.lightGrey,
                                      ),
                                      width: IbConfig.kMcPicHeight,
                                      height: IbConfig.kMcPicHeight,
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
                                Center(
                                  child: IconButton(
                                      padding: EdgeInsets.zero,
                                      onPressed: () {
                                        _controller.picChoiceList.remove(item);
                                      },
                                      icon: const Icon(
                                        Icons.remove,
                                        color: IbColors.errorRed,
                                      )),
                                )
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ))
        ],
      ),
    );
  }

  Widget _picTab() {
    return SingleChildScrollView(
      child: Obx(
        () => ReorderableWrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          runAlignment: WrapAlignment.center,
          onReorder: (int oldIndex, int newIndex) {
            final IbChoice ibChoice = _controller.picList.removeAt(oldIndex);
            _controller.picList.insert(newIndex, ibChoice);
          },
          buildDraggableFeedback: (context, axis, item) {
            return Material(
              color: Colors.transparent,
              child: item,
            );
          },
          header: [
            Obx(() {
              if (_controller.picList.length < IbConfig.kPicChoiceLimit) {
                return GestureDetector(
                  onTap: () {
                    showMediaBottomSheet(context, null, _controller.picList);
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                        color: IbColors.lightGrey,
                        borderRadius: BorderRadius.circular(8)),
                    width: IbConfig.kPicHeight + 8,
                    height: IbConfig.kPicHeight + 8,
                    child: const Icon(Icons.add),
                  ),
                );
              }
              return const SizedBox();
            }),
          ],
          controller: ScrollController(),
          children: _controller.picList
              .map(
                (e) => Stack(
                  children: [
                    InkWell(
                      customBorder: ContinuousRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      onTap: () {
                        showMediaBottomSheet(context, e, _controller.picList);
                      },
                      child: IbCard(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            width: IbConfig.kPicHeight,
                            height: IbConfig.kPicHeight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: e.url!.contains('http')
                                  ? CachedNetworkImage(
                                      imageUrl: e.url!, fit: BoxFit.fill)
                                  : Image.file(
                                      File(e.url!),
                                      fit: BoxFit.fill,
                                    ),
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
    );
  }

  Widget _sCTab() {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        children: [
          const SizedBox(
            height: 8,
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (_controller.scaleEndPoints.length <
                    IbConfig.kScChoiceLimit) {
                  /*_showTextFiledBottomSheet(
                      'add_endpoint', _controller.scaleEndPoints);*/
                } else {
                  IbUtils.showSimpleSnackBar(
                      msg: 'choice_limit_sc'.tr,
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
                      'tap_to_add_sc'.tr,
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
          Obx(
            () => ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                print('$oldIndex to $newIndex');
                _controller.swapIndex(oldIndex, newIndex);
              },
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                for (final item in _controller.scaleEndPoints)
                  GestureDetector(
                    key: UniqueKey(),
                    onTap: () {
                      /* _showEditTextFiledBtmSheet(item);*/
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
                                _controller.scaleEndPoints.remove(item);
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
            ),
          )
        ],
      ),
    );
  }
}

void showMediaBottomSheet(
    BuildContext context, IbChoice? ibChoice, RxList<IbChoice> list) {
  IbUtils.hideKeyboard();
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
            if (ibChoice != null) {
              // ignore: parameter_assignments
              ibChoice!.url = pickedFile.path;
            } else {
              // ignore: parameter_assignments
              ibChoice = IbChoice(
                  choiceId: IbUtils.getUniqueId(), url: pickedFile.path);
              // ignore: parameter_assignments
              list.add(ibChoice!);
            }

            list.refresh();
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
            if (ibChoice != null) {
              // ignore: parameter_assignments
              ibChoice!.url = pickedFile.path;
            } else {
              // ignore: parameter_assignments
              ibChoice = IbChoice(
                choiceId: IbUtils.getUniqueId(),
                url: pickedFile.path,
              );
              // ignore: parameter_assignments
              list.add(ibChoice!);
            }
            list.refresh();
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
      InkWell(
        onTap: () async {
          Get.back();
          final url = await Get.to(
            () => IbTenorPage(),
          );
          if (url != null && url.toString().isNotEmpty) {
            if (ibChoice != null) {
              // ignore: parameter_assignments
              ibChoice!.url = url.toString();
            } else {
              // ignore: parameter_assignments
              ibChoice = IbChoice(
                choiceId: IbUtils.getUniqueId(),
                url: url.toString(),
              );
              // ignore: parameter_assignments
              list.add(ibChoice!);
            }

            list.refresh();
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
                  Icons.gif,
                  color: IbColors.accentColor,
                  size: 24,
                ),
                SizedBox(
                  width: 8,
                ),
                Text(
                  'Choose GIF from Tenor',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
  );

  Get.bottomSheet(options, ignoreSafeArea: false);
}
