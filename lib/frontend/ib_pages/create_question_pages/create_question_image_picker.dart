import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/create_question_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/ib_tenor_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

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
      ),
      body: Obx(
        () => Padding(
          padding: const EdgeInsets.all(8.0),
          child: ReorderableWrap(
            spacing: 16,
            runSpacing: 16,
            footer: _controller.picMediaList.length < IbConfig.kMaxImagesCount
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
              final String url = _controller.picMediaList.removeAt(oldIndex);
              _controller.picMediaList.insert(newIndex, url);
            },
            children: buildList(context, _controller.picMediaList),
          ),
        ),
      ),
    );
  }

  List<Widget> buildList(BuildContext context, List<String> urls) {
    final List<Widget> widgets = [];
    for (int i = 0; i < urls.length; i++) {
      final url = urls[i];
      final String heroTag = IbUtils.getUniqueId();
      widgets.add(
        Hero(
          tag: heroTag,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: url.contains('http')
                        ? CachedNetworkImage(
                            imageUrl: url,
                            fit: BoxFit.cover,
                          )
                        : Image.file(
                            File(url),
                            fit: BoxFit.cover,
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
                        if (url.isNotEmpty) {
                          Get.to(
                              () => IbMediaViewer(
                                    urls: [url],
                                    currentIndex: 0,
                                    heroTag: heroTag,
                                  ),
                              transition: Transition.noTransition);
                        }
                      },
                      onTap: () {
                        showMediaBottomSheet(
                            context, i, _controller.picMediaList);
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
          ),
        ),
      );
    }

    return widgets;
  }

  void showMediaBottomSheet(
      BuildContext context, int? index, RxList<String> list) {
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
              if (index != null) {
                // ignore: parameter_assignments
                list[index] = pickedFile.path;
              } else {
                // ignore: parameter_assignments
                list.add(pickedFile.path);
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
              if (index != null) {
                // ignore: parameter_assignments
                list[index] = pickedFile.path;
              } else {
                // ignore: parameter_assignments
                list.add(pickedFile.path);
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
            final gifUrl = await Get.to(
              () => IbTenorPage(),
            );
            if (gifUrl != null && gifUrl.toString().isNotEmpty) {
              if (index != null) {
                // ignore: parameter_assignments
                list[index] = gifUrl.toString();
              } else {
                list.add(gifUrl.toString());
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
}
