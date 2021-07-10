import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';

import 'ib_config.dart';

class IbUtils {
  IbUtils._();
  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
  static bool isOver13(DateTime dateTime) {
    final bool isOver13 =
        DateTime.now().difference(dateTime).inDays > IbConfig.ageLimitInDays;
    return isOver13;
  }

  static Future<File?> showImageCropper(String filePath) async {
    return ImageCropper.cropImage(
        sourcePath: filePath,
        cropStyle: CropStyle.circle,
        compressQuality: 50,
        aspectRatioPresets: [
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: const AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: IbColors.primaryColor,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: const IOSUiSettings(
          minimumAspectRatio: 1.0,
        ));
  }

  static String getUniqueName() {
    return const Uuid().v4();
  }
}
