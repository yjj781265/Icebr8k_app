import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  static Color getRandomColor(double value) {
    if (value > 0 && value <= 0.2) {
      return const Color(0xFFFF0000);
    }

    if (value > 0.2 && value <= 0.4) {
      return const Color(0xFFFF6600);
    }

    if (value > 0.4 && value <= 0.6) {
      return const Color(0xFFFFB700);
    }

    if (value > 0.6 && value <= 0.7) {
      return const Color(0xFFB1E423);
    }

    if (value > 0.8 && value <= 0.9) {
      return const Color(0xFF23E480);
    }

    if (value > 0.9 && value <= 1.0) {
      return IbColors.accentColor;
    }
    return IbColors.errorRed;
  }

  static void showSimpleSnackBar(
      {required String msg, required Color backgroundColor}) {
    Get.showSnackbar(GetBar(
      borderRadius: IbConfig.kCardCornerRadius,
      margin: const EdgeInsets.all(8),
      duration: const Duration(seconds: 3),
      backgroundColor: backgroundColor,
      messageText: Text(msg),
    ));
  }

  static Future<double> getCompScore(String uid1, String uid2) async {
    final List<IbAnswer> uid1QuestionAnswers =
        await IbQuestionDbService().queryUserAnswers(uid1);
    final List<IbAnswer> uid2QuestionAnswers =
        await IbQuestionDbService().queryUserAnswers(uid2);

    print('uid1 has answered ${uid1QuestionAnswers.length} questions');
    print('uid2 has answered ${uid2QuestionAnswers.length} questions');

    if (uid1QuestionAnswers.isEmpty || uid2QuestionAnswers.isEmpty) {
      return 0;
    }

    final List<String> uid1QuestionIds = [];
    final List<String> uid2QuestionIds = [];

    for (final IbAnswer answer in uid1QuestionAnswers) {
      uid1QuestionIds.add(answer.questionId);
    }

    for (final IbAnswer answer in uid2QuestionAnswers) {
      uid2QuestionIds.add(answer.questionId);
    }

    final int commonQuestionSize =
        uid1QuestionIds.toSet().intersection(uid2QuestionIds.toSet()).length;
    final int commonAnswerSize = uid1QuestionAnswers
        .toSet()
        .intersection(uid2QuestionAnswers.toSet())
        .length;

    print('commonQuestionSize is $commonQuestionSize');
    print('commonAnswerSize is $commonAnswerSize');

    if (commonQuestionSize == 0) {
      return 0;
    }

    final _score = commonAnswerSize / commonQuestionSize.toDouble();
    print('score is $_score');

    return _score;
  }
}
