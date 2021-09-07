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
import 'package:icebr8k/frontend/ib_widgets/ib_single_date_picker.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class EditProfilePage extends StatelessWidget {
  EditProfilePage({Key? key}) : super(key: key);
  final _controller = Get.put(EditProfileController());
  final TextEditingController _nameEditController = TextEditingController();
  final TextEditingController _bioEditController = TextEditingController();
  final TextEditingController _birthdateEditController =
      TextEditingController();
  final HomeController _homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () async {
              final IbUser? ibUser = _homeController.currentIbUser;
              if (ibUser != null) {
                ibUser.birthdateInMs = _controller.birthdateInMs.value;
                ibUser.name = _nameEditController.text.trim();
                ibUser.description = _bioEditController.text.trim();
                _controller.updateUserInfo(ibUser);
              }
            },
          )
        ],
        backgroundColor: IbColors.lightBlue,
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => showEditAvatarBottomSheet(),
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
                        child: Obx(
                          () => IbUserAvatar(
                            avatarUrl: _homeController.currentIbAvatarUrl.value,
                            disableOnTap: true,
                            radius: 56,
                          ),
                        ),
                      ),
                      Positioned(
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: IbColors.accentColor,
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
                    InkWell(
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
                    ),
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

  void showEditAvatarBottomSheet() {
    final Widget options = ListView(
      shrinkWrap: true,
      children: [
        InkWell(
          onTap: () async {
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: 88,
            );

            if (pickedFile != null) {
              final File? croppedFile =
                  await IbUtils.showImageCropper(pickedFile.path);
              if (croppedFile != null) {
                await _controller.updateAvatarUrl(croppedFile.path);
              }
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
            color: IbColors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              imageQuality: 88,
            );

            if (pickedFile != null) {
              final File? croppedFile =
                  await IbUtils.showImageCropper(pickedFile.path);
              if (croppedFile != null) {
                await _controller.updateAvatarUrl(croppedFile.path);
              }
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
            color: IbColors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.photo_album_outlined,
                    color: IbColors.primaryColor,
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

  String _readableDateTime(DateTime _dateTime) {
    final f = DateFormat('MM/dd/yyyy');
    return f.format(_dateTime);
  }

  Widget _getDatePicker() {
    _controller.birthdatePickerInstructionKey.value = 'date_picker_instruction';
    return Obx(
      () => IbSingleDatePicker(
        onSelectionChanged: (arg) {
          _controller.birthdateInMs.value =
              (arg.value as DateTime).millisecondsSinceEpoch;
          _controller.birthdatePickerInstructionKey.value = '';
        },
        titleTrKey: _controller.birthdatePickerInstructionKey.value,
        buttons: [
          TextButton(onPressed: () => Get.back(), child: Text('cancel'.tr)),
          TextButton(
              onPressed: () {
                if (_controller
                    .birthdatePickerInstructionKey.value.isNotEmpty) {
                  return;
                }

                final _dateTime = DateTime.fromMillisecondsSinceEpoch(
                    _controller.birthdateInMs.value);
                _controller.readableBirthdate.value =
                    _readableDateTime(_dateTime);
                _birthdateEditController.text =
                    _controller.readableBirthdate.value;

                Get.back();
              },
              child: Text('confirm'.tr)),
        ],
      ),
    );
  }
}
