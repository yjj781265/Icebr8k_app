import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_settings_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_friends_picker_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/ib_friends_picker.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';

class CircleSettings extends StatelessWidget {
  final CircleSettingsController _controller;

  const CircleSettings(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _controller.ibChat == null
            ? const Text('Create A Circle')
            : _controller.isAbleToEdit
                ? const Text('Edit A Circle')
                : const Text('Circle Info'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () {
            IbUtils.hideKeyboard();
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Obx(
                    () => Column(
                      children: [
                        InkWell(
                          onTap: _controller.isAbleToEdit
                              ? showEditAvatarBottomSheet
                              : null,
                          child: Stack(
                            children: [
                              if (_controller.photoUrl.isEmpty)
                                CircleAvatar(
                                  backgroundColor: IbColors.lightGrey,
                                  radius: 56,
                                  child: Text(
                                    _controller.photoInit.value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Theme.of(context).indicatorColor,
                                        fontSize: 56,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              else
                                IbUserAvatar(
                                  avatarUrl: _controller.photoUrl.value,
                                  radius: 56,
                                ),
                              if (_controller.isAbleToEdit)
                                Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      backgroundColor: Theme.of(context)
                                          .backgroundColor
                                          .withOpacity(0.8),
                                      radius: 16,
                                      child: Icon(
                                        Icons.edit,
                                        color: Theme.of(context).indicatorColor,
                                        size: 16,
                                      ),
                                    ))
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 32,
                        ),

                        /// title
                        Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8))),
                            child: TextField(
                              enabled: _controller.isAbleToEdit,
                              maxLength: 100,
                              controller: _controller.titleTxtController,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: IbConfig.kPageTitleSize),
                              decoration: InputDecoration(
                                counterText: '',
                                hintText: 'circle_title_hint'.tr,
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8))),
                            child: TextField(
                              enabled: _controller.isAbleToEdit,
                              controller: _controller.welcomeMsgController,
                              minLines: 1,
                              maxLines: 5,
                              maxLength: 300,
                              decoration: InputDecoration(
                                hintText: 'circle_welcome_message_hint'.tr,
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            )),
                        const SizedBox(
                          height: 8,
                        ),
                        Container(
                          margin: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(8))),
                          child: TextField(
                            enabled: _controller.isAbleToEdit,
                            minLines: 1,
                            maxLines: 5,
                            maxLength: 500,
                            controller: _controller.descriptionController,
                            decoration: InputDecoration(
                              hintText: 'circle_description_hint'.tr,
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                        ),

                        CheckboxListTile(
                          value: _controller.isPublicCircle.value,
                          dense: true,
                          onChanged: (value) {
                            if (_controller.isAbleToEdit) {
                              _controller.isPublicCircle.value = value ?? false;
                            }
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          title: const Text(
                            'Public',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: IbConfig.kNormalTextSize),
                          ),
                          subtitle: const Text(
                            'Anyone can join the group',
                            style: TextStyle(
                                color: IbColors.lightGrey,
                                fontSize: IbConfig.kSecondaryTextSize),
                          ),
                        ),
                        CheckboxListTile(
                          value: !_controller.isPublicCircle.value,
                          dense: true,
                          onChanged: (value) {
                            if (_controller.isAbleToEdit) {
                              _controller.isPublicCircle.value =
                                  !(value ?? false);
                            }
                          },
                          controlAffinity: ListTileControlAffinity.trailing,
                          title: const Text(
                            'Private',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: IbConfig.kNormalTextSize),
                          ),
                          subtitle: const Text(
                            'Joining requires approval from the circle admin',
                            style: TextStyle(
                                color: IbColors.lightGrey,
                                fontSize: IbConfig.kSecondaryTextSize),
                          ),
                        ),
                        const Divider(
                          height: 16,
                          thickness: 1,
                        ),
                        if (_controller.ibChat == null)
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Invites',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: IbConfig.kNormalTextSize),
                              ),
                            ),
                          ),
                        if (_controller.ibChat == null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ReorderableWrap(
                              spacing: 8,
                              header: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: IbActionButton(
                                      color: IbColors.primaryColor,
                                      iconData: Icons.add,
                                      onPressed: () async {
                                        IbUtils.hideKeyboard();
                                        final list = await Get.to(
                                            () => IbFriendsPicker(
                                                  Get.put(
                                                      IbFriendsPickerController(
                                                          IbUtils
                                                              .getCurrentUid()!,
                                                          pickedUids:
                                                              _controller
                                                                  .invitees
                                                                  .map((p0) =>
                                                                      p0.id)
                                                                  .toList())),
                                                ),
                                            fullscreenDialog: true,
                                            transition: Transition.zoom);

                                        for (final dynamic item in list) {
                                          _controller.invitees
                                              .add(item as IbUser);
                                        }
                                      },
                                      text: ''),
                                ),
                              ],
                              onReorder: (int oldIndex, int newIndex) {},
                              children: _controller.invitees
                                  .map((element) => Opacity(
                                      opacity: 0.8,
                                      child: IbUserAvatar(
                                          avatarUrl: element.avatarUrl)))
                                  .toList(),
                            ),
                          ),
                        const SizedBox(
                          height: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_controller.isAbleToEdit)
                Container(
                  padding: const EdgeInsets.all(8),
                  height: 64,
                  width: double.infinity,
                  child: IbElevatedButton(
                    onPressed: () async {
                      await _controller.onCreateCircle();
                    },
                    textTrKey:
                        _controller.ibChat == null ? 'Create a circle' : 'Save',
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  void showEditAvatarBottomSheet() {
    final Widget options = ListView(
      shrinkWrap: true,
      children: [
        InkWell(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          onTap: () {
            _controller.photoUrl.value = '';
            Get.back();
          },
          child: Ink(
            height: 56,
            width: double.infinity,
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Default Photo'),
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: IbConfig.kImageQuality,
            );

            if (pickedFile != null) {
              final File? croppedFile =
                  await IbUtils.showImageCropper(pickedFile.path);
              if (croppedFile != null) {
                _controller.photoUrl.value = croppedFile.path;
              }
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
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
              final File? croppedFile =
                  await IbUtils.showImageCropper(pickedFile.path);
              if (croppedFile != null) {
                _controller.photoUrl.value = croppedFile.path;
              }
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
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

    Get.bottomSheet(SafeArea(child: IbCard(child: options)));
  }
}
