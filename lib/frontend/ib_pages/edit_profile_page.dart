import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/edit_profile_controller.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatelessWidget {
  EditProfilePage({Key? key}) : super(key: key);
  final _controller = Get.put(EditProfileController());
  final TextEditingController _nameEditController = TextEditingController();
  final TextEditingController _usernameEditController = TextEditingController();
  final TextEditingController _bioEditController = TextEditingController();
  //final TextEditingController _birthdateEditController =
  //   TextEditingController();
  final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final IbUser? ibUser = _homeController.currentIbUser;
              if (ibUser != null) {
                ibUser.birthdateInMs = _controller.birthdateInMs.value == 0
                    ? _homeController.currentBirthdate.value
                    : _controller.birthdateInMs.value;
                //ibUser.name = _nameEditController.text.trim();
                ibUser.username =
                    _usernameEditController.text.trim().toLowerCase();
                // ibUser.description = _bioEditController.text.trim();
                _controller.updateUserInfo(ibUser);
              }
            },
          )
        ],
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => showEditAvatarBottomSheet(context),
              child: SizedBox(
                width: 112,
                height: 112,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.bottomRight,
                    children: [
                      Center(
                        child: Obx(() {
                          if (_controller.isProfilePicPicked.isFalse) {
                            return IbUserAvatar(
                              avatarUrl: _controller.avatarUrl.value,
                              disableOnTap: true,
                              radius: 56,
                            );
                          }
                          return CircleAvatar(
                            radius: 56,
                            key: UniqueKey(),
                            foregroundImage:
                                FileImage(File(_controller.avatarUrl.value)),
                          );
                        }),
                      ),
                      Positioned(
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).primaryColor,
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
                ),
              ),
            ),
            IbCard(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Obx(
                      () => IbTextField(
                          titleIcon: const Icon(
                            Icons.person_outline,
                            color: IbColors.primaryColor,
                          ),
                          titleTrKey: 'name',
                          hintTrKey: 'name_hint',
                          controller: _nameEditController,
                          text: _homeController.currentIbName.value,
                          onChanged: (text) {}),
                    ),
                    Obx(
                      () => IbTextField(
                          textInputType: TextInputType.multiline,
                          titleIcon: const Icon(
                            Icons.person_rounded,
                            color: IbColors.primaryColor,
                          ),
                          titleTrKey: 'bio',
                          hintTrKey: 'bio_hint',
                          maxLines: 8,
                          charLimit: IbConfig.kBioMaxLength,
                          controller: _bioEditController,
                          text: _homeController.currentBio.value,
                          onChanged: (text) {}),
                    ),
                    IbTextField(
                        titleIcon: const Icon(
                          Icons.tag_outlined,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: "username",
                        controller: _usernameEditController,
                        text: _homeController.currentIbUsername.value,
                        charLimit: IbConfig.kUsernameMaxLength,
                        hintTrKey: 'username_hint',
                        onChanged: (text) {
                          _controller.username.value =
                              text.trim().toLowerCase();
                        }),
                    /*    InkWell(
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) => _getDatePicker(),
                          barrierDismissible: false),
                      child: Obx(
                        () => IbTextField(
                          titleIcon: const Icon(
                            Icons.cake_outlined,
                            color: IbColors.primaryColor,
                          ),
                          text: _readableDateTime(
                              DateTime.fromMillisecondsSinceEpoch(
                                  _homeController.currentBirthdate.value)),
                          controller: _birthdateEditController,
                          suffixIcon: const Icon(Icons.calendar_today_outlined),
                          titleTrKey: 'birthdate',
                          hintTrKey: 'birthdate_hint',
                          enabled: false,
                          onChanged: (birthdate) {},
                        ),
                      ),
                    ),*/
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  void showEditAvatarBottomSheet(BuildContext context) {
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
                  height: 1600,
                  width: 1600);
              if (croppedFile != null) {
                _controller.avatarUrl.value = croppedFile.path;
                _controller.isProfilePicPicked.value = true;
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
                  height: 1600,
                  width: 1600);
              if (croppedFile != null) {
                _controller.avatarUrl.value = croppedFile.path;
                _controller.isProfilePicPicked.value = true;
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
}
