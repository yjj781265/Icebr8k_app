import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/setup_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:image_picker/image_picker.dart';

import '../../ib_colors.dart';

class SetupPageThree extends StatelessWidget {
  final SetupController _controller;

  const SetupPageThree(this._controller);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: IbUtils.hideKeyboard,
          child: SafeArea(
              child: Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: bodyWidget(context)),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 56,
                          child: IbElevatedButton(
                            color: IbColors.errorRed,
                            textTrKey: 'back',
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 56,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: IbElevatedButton(
                              color: IbColors.primaryColor,
                              textTrKey: 'Next',
                              onPressed: () async {
                                IbUtils.hideKeyboard();
                                await _controller.validatePageThree();
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget bodyWidget(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                      flex: 8,
                      child: Text(
                        'Create your Icebr8k username, avatar, and bio',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: IbConfig.kSloganSize,
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          color: Theme.of(context).backgroundColor,
                        ),
                        child: const Text(
                          'Step 3/3',
                          style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                        ),
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            IbCard(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Stack(
                      children: [
                        Obx(
                          () => CircleAvatar(
                            radius: 56,
                            backgroundColor: IbColors.lightGrey,
                            foregroundImage: _controller.avatarUrl.isEmpty
                                ? null
                                : FileImage(File(_controller.avatarUrl.value)),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 58,
                              color: IbColors.darkPrimaryColor,
                            ),
                          ),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 3,
                          child: Icon(
                            Icons.camera_alt,
                            color: IbColors.darkPrimaryColor,
                          ),
                        ),
                        Positioned.fill(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: () => showEditAvatarBottomSheet(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    IbTextField(
                        inputFormatter: <TextInputFormatter>[
                          FilteringTextInputFormatter.allow(
                              RegExp('[a-z0-9_.]')),
                          LengthLimitingTextInputFormatter(
                              IbConfig.kUsernameMaxLength)
                        ],
                        controller: _controller.usernameTeController,
                        titleIcon: const Icon(
                          Icons.person_rounded,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: 'username',
                        hintTrKey: 'username_hint',
                        onChanged: (text) {}),
                    IbTextField(
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
                  ],
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  void showEditAvatarBottomSheet(BuildContext context) {
    final Widget options = Column(
      mainAxisSize: MainAxisSize.min,
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
              final File? croppedFile = await IbUtils.showImageCropper(
                  pickedFile.path,
                  height: 1600,
                  width: 1600);
              if (croppedFile != null) {
                _controller.avatarUrl.value = croppedFile.path;
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
