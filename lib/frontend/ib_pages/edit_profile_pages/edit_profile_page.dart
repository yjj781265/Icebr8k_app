import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/edit_profile_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/ib_tenor_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatelessWidget {
  final EditProfileController _controller = Get.put(EditProfileController());
  @override
  Widget build(BuildContext context) {
    const TextStyle headerStyle = TextStyle(
        fontWeight: FontWeight.bold, fontSize: IbConfig.kNormalTextSize);
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'edit_profile'.tr,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Obx(
            () => Row(
              children: [
                const Icon(Icons.remove_red_eye),
                const SizedBox(
                  width: 8,
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton2(
                    offset: const Offset(-8, 0),
                    items: _controller.privacyItems
                        .map((item) => DropdownMenuItem<String>(
                              value: item,
                              child: Text(
                                item,
                                style: const TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ))
                        .toList(),
                    value: _controller.selectedPrivacy.value,
                    onChanged: (value) {
                      _controller.selectedPrivacy.value = value.toString();
                      _controller.onPrivacySelect(value.toString());
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Scrollbar(
              thumbVisibility: true,
              radius: const Radius.circular(8),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('cover_photo'.tr, style: headerStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _editCoverPhotoWidget(context),
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'avatar'.tr,
                        style: headerStyle,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _editAvatarWidget(context),
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('gender'.tr, style: headerStyle),
                    ),
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ToggleButtons(
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                            borderColor: IbColors.lightGrey,
                            selectedColor: IbColors.primaryColor,
                            selectedBorderColor: IbColors.accentColor,
                            borderWidth: 2,
                            onPressed: (index) {
                              _controller.onGenderSelect(index);
                            },
                            isSelected: _controller.genderSelections.toList(),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  IbUser.kGenders[0],
                                  style: TextStyle(
                                      color: Theme.of(context).indicatorColor),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  IbUser.kGenders[1],
                                  style: TextStyle(
                                      color: Theme.of(context).indicatorColor),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  IbUser.kGenders[2],
                                  style: TextStyle(
                                      color: Theme.of(context).indicatorColor),
                                ),
                              )
                            ]),
                      ),
                    ),
                    const Divider(
                      thickness: 2,
                    ),
                    Obx(
                      () => IbTextField(
                        text: _controller.fName.value,
                        controller: _controller.fNameTeController,
                        titleIcon: const Icon(
                          Icons.person_rounded,
                          color: IbColors.primaryColor,
                        ),
                        textInputType: TextInputType.name,
                        titleTrKey: 'fName',
                        hintTrKey: 'fNameHint',
                      ),
                    ),
                    Obx(
                      () => IbTextField(
                        text: _controller.lName.value,
                        controller: _controller.lNameTeController,
                        titleIcon: const Icon(
                          Icons.person_rounded,
                          color: IbColors.primaryColor,
                        ),
                        textInputType: TextInputType.name,
                        titleTrKey: 'lName',
                        hintTrKey: 'lNameHint',
                      ),
                    ),
                    Obx(
                      () => IbTextField(
                          inputFormatter: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                                RegExp('[a-z0-9_.]')),
                            LengthLimitingTextInputFormatter(
                                IbConfig.kUsernameMaxLength)
                          ],
                          text: _controller.username.value,
                          controller: _controller.usernameTeController,
                          titleIcon: const Icon(
                            Icons.person_rounded,
                            color: IbColors.primaryColor,
                          ),
                          titleTrKey: 'username',
                          hintTrKey: 'username_hint',
                          onChanged: (text) {}),
                    ),
                    InkWell(
                      onTap: _showDateTimePicker,
                      child: IbTextField(
                        titleIcon: const Icon(
                          Icons.cake_outlined,
                          color: IbColors.primaryColor,
                        ),
                        controller: _controller.birthdateTeController,
                        text: IbUtils.readableDateTime(
                            DateTime.fromMillisecondsSinceEpoch(
                                _controller.birthdateInMs.value)),
                        suffixIcon: const Icon(Icons.calendar_today_outlined),
                        titleTrKey: 'birthdate',
                        hintTrKey: 'birthdate_hint',
                        enabled: false,
                        onChanged: (birthdate) {},
                      ),
                    ),
                    Obx(
                      () => IbTextField(
                          text: _controller.bio.value,
                          maxLines: IbConfig.kBioMaxLines,
                          charLimit: IbConfig.kBioMaxLength,
                          controller: _controller.bioTeController,
                          titleIcon: const Icon(
                            Icons.edit,
                            color: IbColors.primaryColor,
                          ),
                          titleTrKey: 'bio',
                          hintTrKey: 'bio_hint',
                          onChanged: (text) {}),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: IbElevatedButton(
                  textTrKey: 'save',
                  onPressed: () async {
                    _controller.validate();
                  },
                  icon: const Icon(Icons.save),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _editCoverPhotoWidget(BuildContext context) {
    return Obx(() => Stack(
          alignment: Alignment.center,
          children: [
            if (_controller.coverPhotoUrl.value.contains('http') ||
                _controller.coverPhotoUrl.value.isEmpty)
              CachedNetworkImage(
                  width: Get.width,
                  height: Get.width / 2,
                  fit: BoxFit.fill,
                  imageUrl: _controller.coverPhotoUrl.isEmpty
                      ? IbConfig.kDefaultCoverPhotoUrl
                      : _controller.coverPhotoUrl.value)
            else
              Image.file(
                File(_controller.coverPhotoUrl.value),
                width: Get.width,
                height: Get.width / 2,
                fit: BoxFit.fill,
              ),
            Positioned(
                bottom: 8,
                right: 8,
                child: CircleAvatar(
                    backgroundColor: Theme.of(context).backgroundColor,
                    child: Icon(
                      Icons.image,
                      color: Theme.of(context).indicatorColor,
                      size: 20,
                    ))),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _showCoverPhotoBottomSheet,
                ),
              ),
            ),
          ],
        ));
  }

  Widget _editAvatarWidget(BuildContext context) {
    return GestureDetector(
      onTap: () => showEditAvatarBottomSheet(),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Obx(() {
            if (_controller.avatarUrl.contains('http')) {
              return IbUserAvatar(
                avatarUrl: _controller.avatarUrl.value,
                disableOnTap: true,
                radius: 56,
              );
            }
            return CircleAvatar(
              radius: 56,
              key: UniqueKey(),
              foregroundImage: FileImage(File(_controller.avatarUrl.value)),
            );
          }),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).backgroundColor,
              ),
              child: const Padding(
                padding: EdgeInsets.all(3.0),
                child: Icon(
                  Icons.edit_outlined,
                  size: 16,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showDateTimePicker() {
    IbUtils.hideKeyboard();
    _controller.birthdateTeController.text = IbUtils.readableDateTime(
        DateTime.fromMillisecondsSinceEpoch(_controller.birthdateInMs.value));
    Get.bottomSheet(
        SafeArea(
          child: IbCard(
              child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 256,
                  width: Get.width,
                  child: CupertinoDatePicker(
                    initialDateTime: DateTime.fromMillisecondsSinceEpoch(
                        _controller.birthdateInMs.value),
                    mode: CupertinoDatePickerMode.date,
                    maximumDate: DateTime.now(),
                    onDateTimeChanged: (value) async {
                      await HapticFeedback.selectionClick();
                      _controller.birthdateTeController.text =
                          IbUtils.readableDateTime(value);
                      _controller.birthdateTeController.text;
                      _controller.birthdateInMs.value =
                          value.millisecondsSinceEpoch;
                    },
                    dateOrder: DatePickerDateOrder.mdy,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: Get.width,
                    height: 32,
                    child: IbElevatedButton(
                      onPressed: () {
                        Get.back();
                      },
                      textTrKey: 'ok',
                    ),
                  ),
                ),
              ],
            ),
          )),
        ),
        ignoreSafeArea: false);
  }

  void _showCoverPhotoBottomSheet() {
    final Widget options = ListView(
      shrinkWrap: true,
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
              _controller.coverPhotoUrl.value = url.toString();
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
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: IbConfig.kImageQuality,
            );

            if (pickedFile != null) {
              final file = await IbUtils.showImageCropper(pickedFile.path,
                  lockAspectRatio: true,
                  minimumAspectRatio: 16 / 9,
                  resetAspectRatioEnabled: false,
                  height: 9,
                  width: 16,
                  initAspectRatio: CropAspectRatioPreset.ratio16x9,
                  ratios: <CropAspectRatioPreset>[
                    CropAspectRatioPreset.ratio16x9
                  ],
                  cropStyle: CropStyle.rectangle);

              if (file != null) {
                _controller.coverPhotoUrl.value = file.path;
              }
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
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: IbConfig.kImageQuality,
            );

            if (pickedFile != null) {
              final file = await IbUtils.showImageCropper(pickedFile.path,
                  lockAspectRatio: true,
                  minimumAspectRatio: 16 / 9,
                  resetAspectRatioEnabled: false,
                  height: 9,
                  width: 16,
                  initAspectRatio: CropAspectRatioPreset.ratio16x9,
                  ratios: <CropAspectRatioPreset>[
                    CropAspectRatioPreset.ratio16x9
                  ],
                  cropStyle: CropStyle.rectangle);

              if (file != null) {
                _controller.coverPhotoUrl.value = file.path;
              }
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

    Get.bottomSheet(SafeArea(child: IbCard(child: options)));
  }

  void showEditAvatarBottomSheet() {
    final Widget options = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16))),
          onTap: () async {
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: IbConfig.kImageQuality,
            );

            if (pickedFile != null) {
              final croppedFile = await IbUtils.showImageCropper(
                  pickedFile.path,
                  width: 1600,
                  height: 1600);
              if (croppedFile != null) {
                _controller.avatarUrl.value = croppedFile.path;
              }
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
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: IbConfig.kImageQuality,
            );

            if (pickedFile != null) {
              final croppedFile = await IbUtils.showImageCropper(
                pickedFile.path,
                width: 1600,
                height: 1600,
              );
              if (croppedFile != null) {
                _controller.avatarUrl.value = croppedFile.path;
              }
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

    Get.bottomSheet(SafeArea(child: IbCard(child: options)));
  }
}
