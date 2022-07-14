import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/create_question_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:image_picker/image_picker.dart';

import '../../ib_colors.dart';
import '../../ib_config.dart';
import '../../ib_utils.dart';
import '../ib_premium_page.dart';
import '../ib_tenor_page.dart';

class CreateQuestionMcPicTab extends StatelessWidget {
  final CreateQuestionController _controller;

  const CreateQuestionMcPicTab(this._controller);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ReorderableListView(
        onReorder: (oldIndex, newIndex) {
          _controller.swapIndex(oldIndex, newIndex);
        },
        header: headerWidget(context),
        children: _controller.picChoiceList
            .map((element) => itemWidget(context: context, item: element))
            .toList(),
      ),
    );
  }

  Widget headerWidget(BuildContext context) {
    return IbCard(
      elevation: 0,
      radius: 8,
      child: SizedBox(
        height: IbConfig.kMcPicItemSize,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: IbColors.lightGrey,
                    ),
                    width: IbConfig.kMcPicSize,
                    height: IbConfig.kMcPicSize,
                    child: const Icon(Icons.add),
                  ),
                  Positioned.fill(
                      child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onTap: () {
                        showMediaBottomSheet(
                            context: context, list: _controller.picChoiceList);
                      },
                    ),
                  ))
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  children: [
                    SizedBox(
                      height: IbConfig.kMcPicSize,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 64.0),
                            child: Text(
                              'tap_to_add'.tr,
                              style: const TextStyle(color: IbColors.lightGrey),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 10),
                            child: Icon(Icons.add_outlined),
                          ),
                        ],
                      ),
                    ),
                    Positioned.fill(
                        child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        onTap: () {
                          _showBottomSheet(strTrKey: 'add_choice');
                        },
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget itemWidget({required BuildContext context, required IbChoice item}) {
    return IbCard(
      elevation: 0,
      radius: 8,
      key: ValueKey(item.choiceId),
      child: SizedBox(
        height: IbConfig.kMcPicItemSize,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  _handlePic(context: context, ibChoice: item),
                  Positioned.fill(
                      child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onTap: () {
                        showMediaBottomSheet(
                            context: context,
                            list: _controller.picChoiceList,
                            ibChoice: item);
                      },
                      onDoubleTap: () {
                        if (item.url == null) {
                          return;
                        }
                        Get.to(
                            () => IbMediaViewer(
                                urls: [item.url!], currentIndex: 0),
                            transition: Transition.zoom);
                      },
                    ),
                  ))
                ],
              ),
            ),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: IbConfig.kMcPicSize,
                    alignment: Alignment.center,
                    child: Text(
                      item.content == null ? 'tap_to_add'.tr : item.content!,
                      style: TextStyle(
                          color:
                              item.content == null ? IbColors.lightGrey : null),
                    ),
                  ),
                  Positioned.fill(
                      child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      customBorder: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      onTap: () {
                        _showBottomSheet(
                            strTrKey: 'add_choice',
                            index: _controller.picChoiceList.indexOf(item));
                      },
                    ),
                  ))
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _controller.picChoiceList.remove(item);
              },
              icon: const Icon(
                Icons.remove,
                color: IbColors.errorRed,
              ),
              padding: EdgeInsets.zero,
            ),
            const SizedBox(
              width: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _handlePic(
      {required BuildContext context, required IbChoice ibChoice}) {
    if (ibChoice.url == null || ibChoice.url!.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: IbColors.lightGrey,
        ),
        width: IbConfig.kMcPicSize,
        height: IbConfig.kMcPicSize,
        child: const Icon(Icons.add),
      );
    }

    if (ibChoice.url!.contains('http')) {
      return ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: CachedNetworkImage(
          placeholder: (context, string) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: IbColors.lightGrey,
              ),
              width: IbConfig.kMcPicSize,
              height: IbConfig.kMcPicSize,
            );
          },
          imageUrl: ibChoice.url!,
          fit: BoxFit.fill,
          width: IbConfig.kMcPicSize,
          height: IbConfig.kMcPicSize,
        ),
      );
    }

    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Image.file(
        File(ibChoice.url!),
        fit: BoxFit.fill,
        width: IbConfig.kMcPicSize,
        height: IbConfig.kMcPicSize,
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
      _controller.picChoiceList[index].content = value.trim();
    } else {
      _controller.picChoiceList.add(IbChoice(
        choiceId: IbUtils().getUniqueId(),
        content: value.trim(),
      ));
    }
    _controller.picChoiceList.refresh();
    Get.back();
  }

  void _showBottomSheet({required String strTrKey, int? index}) {
    IbUtils().hideKeyboard();
    final TextEditingController _txtController = TextEditingController();
    if (index != null) {
      _txtController.text = _controller.picChoiceList[index].content ?? '';
    }
    final Widget _widget = IbDialog(
      title: strTrKey.tr,
      content: TextField(
        textInputAction: TextInputAction.done,
        maxLength: IbConfig.kAnswerMaxLength,
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
    Get.bottomSheet(_widget, persistent: true);
  }

  void showMediaBottomSheet(
      {required BuildContext context,
      IbChoice? ibChoice,
      required RxList<IbChoice> list}) {
    IbUtils().hideKeyboard();
    final Widget options = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
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
                  choiceId: IbUtils().getUniqueId(),
                  url: url.toString(),
                );
                // ignore: parameter_assignments
                list.add(ibChoice!);
              }

              list.refresh();
            }
          },
          leading: const Icon(
            Icons.gif,
            color: IbColors.accentColor,
            size: 24,
          ),
          title: const Text(
            'Choose GIF from Tenor',
            style: TextStyle(fontSize: IbConfig.kNormalTextSize),
          ),
        ),
        ListTile(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          onTap: () async {
            if (!IbUtils().isPremiumMember()) {
              _showPremiumDialog();
              return;
            }
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
                    choiceId: IbUtils().getUniqueId(), url: pickedFile.path);
                // ignore: parameter_assignments
                list.add(ibChoice!);
              }

              list.refresh();
            }
          },
          leading: const Icon(
            Icons.camera_alt_outlined,
            color: IbColors.primaryColor,
          ),
          title: const Text('Take a photo',
              style: TextStyle(fontSize: IbConfig.kNormalTextSize)),
        ),
        ListTile(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          onTap: () async {
            if (!IbUtils().isPremiumMember()) {
              _showPremiumDialog();
              return;
            }
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
                  choiceId: IbUtils().getUniqueId(),
                  url: pickedFile.path,
                );
                // ignore: parameter_assignments
                list.add(ibChoice!);
              }
              list.refresh();
            }
          },
          leading: const Icon(
            Icons.photo_album_outlined,
            color: IbColors.errorRed,
          ),
          title: const Text(
            'Choose from gallery',
            style: TextStyle(fontSize: IbConfig.kNormalTextSize),
          ),
        ),
      ],
    );

    Get.bottomSheet(IbCard(child: options), ignoreSafeArea: false);
  }

  void _showPremiumDialog() {
    if (!IbUtils().isPremiumMember()) {
      Get.dialog(IbDialog(
        title: 'Premium Only Feature',
        subtitle: 'Go premium to enjoy poll with your own pic',
        positiveTextKey: 'Go Premium',
        onPositiveTap: () {
          Get.back();
          Get.to(() => IbPremiumPage());
        },
      ));
    }
  }
}
