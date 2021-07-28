import 'dart:io';

import 'package:flutter/material.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:uuid/uuid.dart';

import 'ib_config.dart';

class IbUtils {
  IbUtils._();
  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
  static bool isOver13(DateTime dateTime) {
    final bool isOver13 =
        DateTime.now().difference(dateTime).inDays > IbConfig.kAgeLimitInDays;
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

  static String getAgoDateTimeString(DateTime _dateTime) {
    final Duration diffDt = DateTime.now().difference(_dateTime);
    if (diffDt.inSeconds == 0) {
      return 'now';
    }

    if (diffDt.inSeconds < 60) {
      return '${diffDt.inSeconds} sec ago';
    }

    if (diffDt.inMinutes >= 1 && diffDt.inMinutes < 60) {
      return '${diffDt.inMinutes} min ago';
    }

    if (diffDt.inHours >= 1 && diffDt.inHours < 24) {
      return '${diffDt.inHours} hr ago';
    }

    if (diffDt.inDays >= 1 && diffDt.inDays < 30) {
      return '${diffDt.inDays} days ago';
    }

    if (diffDt.inDays >= 30 && diffDt.inDays < 365) {
      return '${diffDt.inDays / 12} mo ago';
    }

    if (diffDt.inDays == 365) {
      return '1 yr ago';
    }

    if (diffDt.inDays > 365) {
      return '${diffDt.inDays ~/ 365} yr ago';
    }
    return '${diffDt.inDays} days ago';
  }

  static Color getRandomColor() {
    final List<Color> colors = [
      Colors.lightBlue,
      Colors.greenAccent,
      Colors.redAccent,
      Colors.lightBlueAccent,
      Colors.orangeAccent,
      IbColors.primaryColor,
      IbColors.accentColor,
      IbColors.darkPrimaryColor,
    ];
    colors.shuffle();
    return colors.first;
  }

  static Future<double> getCompScore(String uid1, String uid2) async {
    final List<IbAnswer> uid1QuestionAnswers =
        await IbQuestionDbService().queryUserAnswers(uid1);
    final List<IbAnswer> uid2QuestionAnswers =
        await IbQuestionDbService().queryUserAnswers(uid2);

    if (uid1QuestionAnswers.isEmpty || uid2QuestionAnswers.isEmpty) {
      return 0;
    }

    final int uid1AnsweredQuestionSize = uid1QuestionAnswers.length;

    uid1QuestionAnswers
        .removeWhere((element) => !uid2QuestionAnswers.contains(element));

    //now uid1QuestionAnswers will contain  questions with same answer between uid1 and uid2
    final _score =
        uid1QuestionAnswers.length.toDouble() / uid1AnsweredQuestionSize;
    return _score;
  }
}
