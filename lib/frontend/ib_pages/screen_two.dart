import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';

class ScreenTwo extends StatelessWidget {
  ScreenTwo({Key? key}) : super(key: key);
  final Widget selfie =
      Lottie.asset('assets/images/selfie.json', key: UniqueKey());
  final SetUpController _setUpController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      appBar: AppBar(
        backgroundColor: IbColors.lightBlue,
        actions: [
          IconButton(
              onPressed: () async {
                await _setUpController.validateScreenTwo();
              },
              icon: const Icon(Icons.check))
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'selfie_time'.tr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 36,
                  ),
                ),
              ),
              Obx(
                () => SizedBox(
                    width: 230,
                    height: 230,
                    child: _setUpController.avatarFilePath.value.isNotEmpty
                        ? CircleAvatar(
                            key: UniqueKey(),
                            foregroundImage: FileImage(
                                File(_setUpController.avatarFilePath.value)),
                          )
                        : selfie),
              ),
              const SizedBox(
                height: 16,
              ),
              IbElevatedButton(
                  color: IbColors.primaryColor,
                  icon: const Icon(
                    Icons.camera_alt_outlined,
                    color: IbColors.white,
                  ),
                  textTrKey: 'camera',
                  onPressed: () async {
                    final _picker = ImagePicker();
                    final XFile? pickedFile = await _picker.pickImage(
                      source: ImageSource.camera,
                      preferredCameraDevice: CameraDevice.front,
                      imageQuality: 90,
                    );
                    if (pickedFile != null) {
                      Get.dialog(
                          const IbLoadingDialog(messageTrKey: 'loading'));
                      final File? croppedFile =
                          await IbUtils.showImageCropper(pickedFile.path);
                      if (croppedFile != null) {
                        _setUpController.avatarFilePath.value =
                            croppedFile.path;
                      }
                      Get.back();
                    }
                  }),
              IbElevatedButton(
                  icon: const Icon(
                    Icons.photo_album_outlined,
                    color: IbColors.white,
                  ),
                  color: IbColors.errorRed,
                  textTrKey: 'gallery',
                  onPressed: () async {
                    final _picker = ImagePicker();
                    final XFile? pickedFile = await _picker.pickImage(
                        source: ImageSource.gallery, imageQuality: 90);
                    if (pickedFile != null) {
                      Get.dialog(
                          const IbLoadingDialog(messageTrKey: 'loading'));
                      final File? croppedFile =
                          await IbUtils.showImageCropper(pickedFile.path);
                      if (croppedFile != null) {
                        _setUpController.avatarFilePath.value =
                            croppedFile.path;
                      }
                      Get.back();
                    }
                  }),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
