import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
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
      if (diffDt.inDays == 1) {
        return '${diffDt.inDays} day ago';
      }
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

  /// Returns the difference (in full days) between the provided date and today.
  static int _calculateDifference(DateTime date) {
    final DateTime now = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .difference(DateTime(now.year, now.month, now.day))
        .inDays;
  }

  static String getStatsString(int num) {
    if (num < 10000) {
      return num.toString();
    }

    final String d = (num.toDouble() / 1000).toStringAsFixed(0);
    return '${d}k';
  }

  static String getSuffixDateTimeString(DateTime _dateTime) {
    if (_calculateDifference(_dateTime) == 0) {
      return 'today';
    }

    if (_calculateDifference(_dateTime) == 1) {
      return 'tomorrow';
    }

    if (_calculateDifference(_dateTime) == -1) {
      return 'yesterday';
    }

    final Duration diffDt = DateTime.now().difference(_dateTime);
    if (diffDt.inDays >= 30 && diffDt.inDays < 365) {
      final DateFormat formatter = DateFormat('MM/dd');
      final String formatted = formatter.format(_dateTime);
      return 'on $formatted';
    } else {
      final DateFormat formatter = DateFormat('MM/dd/yyyy');
      final String formatted = formatter.format(_dateTime);
      return 'on $formatted';
    }
  }

  static String getChatDateTimeString(DateTime _dateTime) {
    final Duration diffDt = DateTime.now().difference(_dateTime);
    if (diffDt.inSeconds == 0) {
      return 'now';
    }

    if (diffDt.inSeconds < 60) {
      return '${diffDt.inSeconds} s';
    }

    if (diffDt.inMinutes >= 1 && diffDt.inMinutes < 60) {
      return '${diffDt.inMinutes} min';
    }

    if (diffDt.inHours >= 1 && diffDt.inHours < 24) {
      return '${diffDt.inHours} hr';
    }

    if (diffDt.inDays >= 1 && diffDt.inDays < 30) {
      return '${diffDt.inDays} d';
    }

    if (diffDt.inDays >= 30 && diffDt.inDays < 365) {
      final DateFormat formatter = DateFormat('MM/dd');
      final String formatted = formatter.format(_dateTime);
      return formatted;
    }

    if (diffDt.inDays == 365) {
      final DateFormat formatter = DateFormat('MM/dd/yyyy');
      final String formatted = formatter.format(_dateTime);
      return formatted;
    }

    if (diffDt.inDays > 365) {
      final DateFormat formatter = DateFormat('MM/dd/yyyy');
      final String formatted = formatter.format(_dateTime);
      return formatted;
    }
    final DateFormat formatter = DateFormat('MM/dd/yyyy');
    final String formatted = formatter.format(_dateTime);
    return formatted;
  }

  static String? getCurrentUid() {
    if (Get.find<AuthController>().firebaseUser == null) {
      return null;
    }
    return Get.find<AuthController>().firebaseUser!.uid;
  }

  static IbUser? getCurrentIbUser() {
    if (Get.find<AuthController>().firebaseUser == null) {
      return null;
    }
    return Get.find<AuthController>().ibUser;
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

    if (commonQuestionSize == 0) {
      return 0;
    }

    final _score = commonAnswerSize / commonQuestionSize.toDouble();
    print('score is $_score');

    return _score;
  }

  static Future<List<IbAnswer>> getCommonAnswersQ(
      String uid1, String uid2) async {
    /// query each user answered questions then intersect
    final List<IbAnswer> uid1QuestionAnswers =
        await IbQuestionDbService().queryUserAnswers(uid1);
    final List<IbAnswer> uid2QuestionAnswers =
        await IbQuestionDbService().queryUserAnswers(uid2);

    return uid1QuestionAnswers
        .toSet()
        .intersection(uid2QuestionAnswers.toSet())
        .toList();
  }

  static Color getRandomColor() {
    final Random random = Random();
    final List<Color> _colors = [
      IbColors.primaryColor,
      IbColors.accentColor,
      IbColors.darkPrimaryColor,
    ];
    _colors.addAll(Colors.accents);
    _colors.addAll(Colors.primaries);
    _colors.remove(Colors.yellowAccent);
    _colors.remove(Colors.yellow);
    _colors.remove(Colors.amberAccent);
    _colors.remove(Colors.amber);
    return _colors[random.nextInt(_colors.length)];
  }
}
