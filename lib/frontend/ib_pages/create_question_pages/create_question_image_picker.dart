import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/ib_tenor_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

import '../../../backend/controllers/user_controllers/create_question_controller.dart';

class CreateQuestionImagePicker extends StatelessWidget {
  final CreateQuestionController _controller;

  const CreateQuestionImagePicker(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
              '${_controller.picMediaList.length}/${IbConfig.kMaxImagesCount} Images Picked'),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('confirm'.tr))
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'double_tap_pic'.tr,
              style: const TextStyle(
                  fontSize: IbConfig.kDescriptionTextSize,
                  color: IbColors.lightGrey),
            ),
          ),
          Obx(
            () => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ReorderableWrap(
                spacing: 16,
                runSpacing: 16,
                footer:
                    _controller.picMediaList.length < IbConfig.kMaxImagesCount
                        ? InkWell(
                            onTap: () => showMediaBottomSheet(
                                context, null, _controller.picMediaList),
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: const BoxDecoration(
                                color: IbColors.lightGrey,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 36,
                              ),
                            ),
                          )
                        : null,
                buildDraggableFeedback: (context, axis, item) {
                  return Material(
                    color: Colors.transparent,
                    child: item,
                  );
                },
                onReorder: (int oldIndex, int newIndex) {
                  final IbMedia media =
                      _controller.picMediaList.removeAt(oldIndex);
                  _controller.picMediaList.insert(newIndex, media);
                },
                children: buildList(
                    context: context, medias: _controller.picMediaList),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> buildList(
      {required BuildContext context, required List<IbMedia> medias}) {
    final List<Widget> widgets = [];
    for (int i = 0; i < medias.length; i++) {
      final media = medias[i];
      widgets.add(
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: SizedBox(
                width: 100,
                height: 100,
                child: media.url.contains('http')
                    ? CachedNetworkImage(
                        placeholder: (context, string) {
                          return Container(
                            width: 100,
                            height: 100,
                            decoration: const BoxDecoration(
                              color: IbColors.lightGrey,
                              borderRadius: BorderRadius.all(
                                Radius.circular(8),
                              ),
                            ),
                          );
                        },
                        imageUrl: media.url,
                        fit: BoxFit.fill,
                      )
                    : Image.file(
                        File(media.url),
                        fit: BoxFit.fill,
                      ),
              ),
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  onDoubleTap: () {
                    if (media.url.isNotEmpty) {
                      Get.to(
                          () => IbMediaViewer(
                                urls: [media.url],
                                currentIndex: 0,
                              ),
                          transition: Transition.zoom);
                    }
                  },
                  onTap: () {
                    showMediaBottomSheet(context, i, _controller.picMediaList);
                  },
                ),
              ),
            ),
            Positioned(
              top: -8,
              right: -8,
              child: CircleAvatar(
                radius: 14,
                backgroundColor: Theme.of(context).backgroundColor,
                child: Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      _controller.picMediaList.removeAt(i);
                    },
                    icon: const Icon(Icons.remove),
                    color: IbColors.errorRed,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return widgets;
  }

  void showMediaBottomSheet(
      BuildContext context, int? index, RxList<IbMedia> list) {
    final Widget options = IbCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () async {
              Get.back();
              final _picker = ImagePicker();
              final XFile? pickedFile = await _picker.pickImage(
                source: ImageSource.camera,
                imageQuality: IbConfig.kImageQuality,
              );

              if (pickedFile != null) {
                if (index != null) {
                  // ignore: parameter_assignments
                  list[index] = IbMedia(
                      url: pickedFile.path,
                      id: IbUtils.getUniqueId(),
                      type: IbMedia.kPicType);
                } else {
                  // ignore: parameter_assignments
                  list.add(IbMedia(
                      url: pickedFile.path,
                      id: IbUtils.getUniqueId(),
                      type: IbMedia.kPicType));
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
            onTap: () async {
              Get.back();
              final _picker = ImagePicker();
              if (index == null) {
                final List<XFile>? pickedFiles = await _picker.pickMultiImage(
                  imageQuality: IbConfig.kImageQuality,
                );

                if (pickedFiles != null) {
                  if (pickedFiles.length + _controller.picMediaList.length >
                      IbConfig.kMaxImagesCount) {
                    IbUtils.showSimpleSnackBar(
                        msg: '4 Pictures Max',
                        backgroundColor: IbColors.errorRed);
                    return;
                  }

                  for (final xFile in pickedFiles) {
                    list.add(IbMedia(
                        url: xFile.path,
                        id: IbUtils.getUniqueId(),
                        type: IbMedia.kPicType));
                  }
                }
                return;
              }

              final XFile? pickedFile = await _picker.pickImage(
                source: ImageSource.gallery,
                imageQuality: IbConfig.kImageQuality,
              );

              if (pickedFile != null) {
                list[index] = IbMedia(
                    url: pickedFile.path,
                    id: IbUtils.getUniqueId(),
                    type: IbMedia.kPicType);

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
          ListTile(
            onTap: () async {
              Get.back();
              final gifUrl = await Get.to(
                () => IbTenorPage(),
              );
              if (gifUrl != null && gifUrl.toString().isNotEmpty) {
                if (index != null) {
                  // ignore: parameter_assignments
                  list[index] = IbMedia(
                      url: gifUrl.toString(),
                      id: IbUtils.getUniqueId(),
                      type: IbMedia.kPicType);
                } else {
                  list.add(IbMedia(
                      url: gifUrl.toString(),
                      id: IbUtils.getUniqueId(),
                      type: IbMedia.kPicType));
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
        ],
      ),
    );

    Get.bottomSheet(options, ignoreSafeArea: false);
  }
}
