import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../backend/controllers/user_controllers/auth_controller.dart';
import '../backend/services/user_services/ib_question_db_service.dart';
import 'ib_config.dart';

class IbUtils {
  IbUtils._();
  static void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
  static bool isOver13(DateTime dateTime) {
    final bool isOver13 =
        DateTime.now().difference(dateTime).inDays > IbConfig.kAgeLimitInDays;
    return isOver13;
  }

  static int calculateAge(int timestampInMs) {
    final DateTime currentDate = DateTime.now();
    final DateTime birthDate =
        DateTime.fromMillisecondsSinceEpoch(timestampInMs);
    int age = currentDate.year - birthDate.year;
    final int month1 = currentDate.month;
    final int month2 = birthDate.month;
    if (month2 > month1) {
      age--;
    } else if (month1 == month2) {
      final int day1 = currentDate.day;
      final int day2 = birthDate.day;
      if (day2 > day1) {
        age--;
      }
    }
    return age;
  }

  static Future<File?> showImageCropper(String filePath,
      {CropStyle cropStyle = CropStyle.circle,
      List<CropAspectRatioPreset> ratios = const [
        CropAspectRatioPreset.original,
      ],
      bool resetAspectRatioEnabled = true,
      double? width,
      double? height,
      CropAspectRatioPreset initAspectRatio = CropAspectRatioPreset.original,
      bool lockAspectRatio = false,
      double? minimumAspectRatio}) async {
    return ImageCropper().cropImage(
        sourcePath: filePath,
        cropStyle: cropStyle,
        aspectRatioPresets: ratios,
        androidUiSettings: AndroidUiSettings(
            toolbarColor: IbColors.darkPrimaryColor,
            toolbarTitle: 'Image Cropper',
            initAspectRatio: initAspectRatio,
            lockAspectRatio: lockAspectRatio),
        iosUiSettings: IOSUiSettings(
          rectHeight: height ?? 900,
          rectWidth: width ?? 1600,
          rectX: width ?? 1600,
          rectY: height ?? 900,
          resetAspectRatioEnabled: resetAspectRatioEnabled,
          resetButtonHidden: !resetAspectRatioEnabled,
          minimumAspectRatio: minimumAspectRatio,
          title: 'Image Cropper',
        ));
  }

  static String getUniqueId() {
    return const Uuid().v4();
  }

  static String readableDateTime(DateTime _dateTime, {bool showTime = false}) {
    if (showTime) {
      return '${DateFormat('hh:mm aa').format(_dateTime)} ${getSuffixDateTimeString(_dateTime)}';
    }
    final f = DateFormat('MM/dd/yyyy');
    return f.format(_dateTime);
  }

  static String getAgoDateTimeString(DateTime _dateTime) {
    final Duration diffDt = DateTime.now().difference(_dateTime);
    if (diffDt.inSeconds < 0) {
      return '';
    }

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
      return '${(diffDt.inDays / 30).toStringAsPrecision(1)} mo ago';
    }

    if (diffDt.inDays == 365) {
      return '1 yr ago';
    }

    if (diffDt.inDays > 365) {
      return '${diffDt.inDays / 365} yr ago';
    }
    return '${diffDt.inDays} days ago';
  }

  static String getDistanceString(double distanceInKm,
      {bool isMetric = false}) {
    final double foot = 3.28084 * distanceInKm * 1000;
    if (foot < 528) {
      return '${foot.toPrecision(1)} ft';
    }
    return '${(foot / 5280).toPrecision(1)} mi';
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
      return '';
    }

    if (_calculateDifference(_dateTime) == 1) {
      return 'tomorrow';
    }

    if (_calculateDifference(_dateTime) == -1) {
      return 'yesterday';
    }

    final Duration diffDt = DateTime.now().difference(_dateTime);
    if (diffDt.inDays < 365) {
      final DateFormat formatter = DateFormat('MM/dd');
      final String formatted = formatter.format(_dateTime);
      return formatted;
    } else {
      final DateFormat formatter = DateFormat('MM/dd/yyyy');
      final String formatted = formatter.format(_dateTime);
      return formatted;
    }
  }

  static String getChatTabDateString(DateTime _dateTime) {
    final Duration diffDt = DateTime.now().difference(_dateTime);
    if (diffDt.inSeconds == 0) {
      return 'now';
    }

    if (diffDt.inSeconds < 60) {
      return '${diffDt.inSeconds} s ago';
    }

    if (diffDt.inMinutes >= 1 && diffDt.inMinutes < 60) {
      return '${diffDt.inMinutes} min ago';
    }

    if (diffDt.inHours >= 1 && diffDt.inHours < 24) {
      return '${diffDt.inHours} hr ago';
    }

    if (diffDt.inDays >= 1 && diffDt.inDays < 30) {
      return '${diffDt.inDays} d ago';
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
    if (!Get.isRegistered<MainPageController>()) {
      return null;
    }
    return Get.find<MainPageController>().rxCurrentIbUser.value;
  }

  static User? getCurrentFbUser() {
    if (Get.find<AuthController>().firebaseUser == null) {
      return null;
    }
    return Get.find<AuthController>().firebaseUser;
  }

  static void showSimpleSnackBar(
      {required String msg, required Color backgroundColor}) {
    Widget icon = const SizedBox();
    if (backgroundColor == IbColors.primaryColor) {
      icon = Icon(
        Icons.info_rounded,
        color: backgroundColor,
      );
    } else if (backgroundColor == IbColors.accentColor) {
      icon = Icon(
        Icons.check_circle_rounded,
        color: backgroundColor,
      );
    } else if (backgroundColor == IbColors.errorRed) {
      icon = Icon(Icons.error_rounded, color: backgroundColor);
    } else {
      icon = Icon(
        Icons.info_rounded,
        color: backgroundColor,
      );
    }

    Get.showSnackbar(GetSnackBar(
      icon: icon,
      snackPosition: SnackPosition.TOP,
      borderRadius: IbConfig.kCardCornerRadius,
      margin: const EdgeInsets.only(left: 8, right: 8, top: 16),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(Get.context!).backgroundColor,
      messageText: Text(
        msg,
        style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
      ),
    ));
  }

  static Future<double> getCompScore(
      {required String uid, bool isRefresh = false}) async {
    final List<IbAnswer> uid1QuestionAnswers = [];
    final List<IbAnswer> uid2QuestionAnswers = [];
    if (IbCacheManager().getIbAnswers(getCurrentUid()!) == null || isRefresh) {
      final tempList =
          await IbQuestionDbService().queryUserAnswers(getCurrentUid()!);
      IbCacheManager()
          .cacheIbAnswers(uid: getCurrentUid()!, ibAnswers: tempList);
      uid1QuestionAnswers.addAll(tempList);
    } else {
      uid1QuestionAnswers
          .addAll(IbCacheManager().getIbAnswers(getCurrentUid()!)!);
    }

    if (IbCacheManager().getIbAnswers(uid) == null || isRefresh) {
      final tempList = await IbQuestionDbService().queryUserAnswers(uid);
      IbCacheManager().cacheIbAnswers(uid: uid, ibAnswers: tempList);
      uid2QuestionAnswers.addAll(tempList);
    } else {
      uid2QuestionAnswers.addAll(IbCacheManager().getIbAnswers(uid)!);
    }

    if (uid1QuestionAnswers.isEmpty || uid2QuestionAnswers.isEmpty) {
      return 0;
    }

    final int commonQuestionSize = uid1QuestionAnswers
        .map((e) => e.questionId)
        .toSet()
        .intersection(uid2QuestionAnswers.map((e) => e.questionId).toSet())
        .length;

    if (commonQuestionSize == 0) {
      return 0;
    }

    final List<IbAnswer> commonAnswers = [];
    final List<String> questionIds = uid1QuestionAnswers
        .map((e) => e.questionId)
        .toSet()
        .intersection(uid2QuestionAnswers.map((e) => e.questionId).toSet())
        .toList();

    for (final String id in questionIds) {
      final IbAnswer? uid1Answer = uid1QuestionAnswers
          .firstWhereOrNull((element) => element.questionId == id);
      final IbAnswer? uid2Answer = uid2QuestionAnswers
          .firstWhereOrNull((element) => element.questionId == id);
      if (uid1Answer == null || uid2Answer == null) {
        continue;
      } else if (uid1Answer.choiceId == uid2Answer.choiceId) {
        commonAnswers.add(uid1Answer);
      }
    }
    commonAnswers
        .sort((a, b) => b.answeredTimeInMs.compareTo(a.answeredTimeInMs));

    final _score =
        commonAnswers.length.toDouble() / commonQuestionSize.toDouble();
    print('score is $_score');

    return _score;
  }

  static Future<List<String>> getCommonAnswerQuestionIds(
      {required String uid, bool isRefresh = false}) async {
    /// query each user answered questions then intersect
    final List<IbAnswer> uid1QuestionAnswers = [];
    final List<IbAnswer> uid2QuestionAnswers = [];
    if (IbCacheManager().getIbAnswers(getCurrentUid()!) == null || isRefresh) {
      final tempList =
          await IbQuestionDbService().queryUserAnswers(getCurrentUid()!);
      IbCacheManager()
          .cacheIbAnswers(uid: getCurrentUid()!, ibAnswers: tempList);
      uid1QuestionAnswers.addAll(tempList);
    } else {
      uid1QuestionAnswers
          .addAll(IbCacheManager().getIbAnswers(getCurrentUid()!)!);
    }

    if (IbCacheManager().getIbAnswers(uid) == null || isRefresh) {
      final tempList = await IbQuestionDbService().queryUserAnswers(uid);
      IbCacheManager().cacheIbAnswers(uid: uid, ibAnswers: tempList);
      uid2QuestionAnswers.addAll(tempList);
    } else {
      uid2QuestionAnswers.addAll(IbCacheManager().getIbAnswers(uid)!);
    }

    final List<IbAnswer> commonAnswers = [];
    final List<String> questionIds = uid1QuestionAnswers
        .map((e) => e.questionId)
        .toSet()
        .intersection(uid2QuestionAnswers.map((e) => e.questionId).toSet())
        .toList();

    for (final String id in questionIds) {
      final IbAnswer? uid1Answer = uid1QuestionAnswers
          .firstWhereOrNull((element) => element.questionId == id);
      final IbAnswer? uid2Answer = uid2QuestionAnswers
          .firstWhereOrNull((element) => element.questionId == id);
      if (uid1Answer == null || uid2Answer == null) {
        continue;
      } else if (uid1Answer.choiceId == uid2Answer.choiceId) {
        commonAnswers.add(uid1Answer);
      }
    }
    commonAnswers
        .sort((a, b) => b.answeredTimeInMs.compareTo(a.answeredTimeInMs));
    return commonAnswers.map((e) => e.questionId).toList();
  }

  static Future<List<String>> getUncommonAnswerQuestionIds(
      {required String uid, bool isRefresh = false}) async {
    /// query each user answered questions then find the difference
    final List<IbAnswer> uid1QuestionAnswers = [];
    final List<IbAnswer> uid2QuestionAnswers = [];
    if (IbCacheManager().getIbAnswers(getCurrentUid()!) == null || isRefresh) {
      final tempList =
          await IbQuestionDbService().queryUserAnswers(getCurrentUid()!);
      IbCacheManager()
          .cacheIbAnswers(uid: getCurrentUid()!, ibAnswers: tempList);
      uid1QuestionAnswers.addAll(tempList);
    } else {
      uid1QuestionAnswers
          .addAll(IbCacheManager().getIbAnswers(getCurrentUid()!)!);
    }

    if (IbCacheManager().getIbAnswers(uid) == null || isRefresh) {
      final tempList = await IbQuestionDbService().queryUserAnswers(uid);
      IbCacheManager().cacheIbAnswers(uid: uid, ibAnswers: tempList);
      uid2QuestionAnswers.addAll(tempList);
    } else {
      uid2QuestionAnswers.addAll(IbCacheManager().getIbAnswers(uid)!);
    }

    final List<String> commonQuestionIds = uid1QuestionAnswers
        .map((e) => e.questionId)
        .toSet()
        .intersection(uid2QuestionAnswers.map((e) => e.questionId).toSet())
        .toList();

    final List<IbAnswer> uncommonAnswers = [];

    for (final String id in commonQuestionIds) {
      final IbAnswer? uid1Answer = uid1QuestionAnswers
          .firstWhereOrNull((element) => element.questionId == id);
      final IbAnswer? uid2Answer = uid2QuestionAnswers
          .firstWhereOrNull((element) => element.questionId == id);
      if (uid1Answer == null || uid2Answer == null) {
        continue;
      } else if (uid1Answer.choiceId != uid2Answer.choiceId) {
        uncommonAnswers.add(uid1Answer);
      }
    }
    uncommonAnswers
        .sort((a, b) => b.answeredTimeInMs.compareTo(a.answeredTimeInMs));
    return uncommonAnswers.map((e) => e.questionId).toList();
  }

  static Future<List<IbAnswer>> getIbAnswers(
      {required List<String> uids,
      required String questionId,
      bool isRefresh = false}) async {
    final List<IbAnswer> theAnswers = [];

    /// look for ibAnswer in cache first

    for (final String uid in uids.toSet()) {
      if (IbCacheManager().getIbAnswers(uid) == null || isRefresh) {
        final answer =
            await IbQuestionDbService().querySingleIbAnswer(uid, questionId);
        if (answer == null) {
          continue;
        }
        theAnswers.add(answer);
      } else {
        final List<IbAnswer> answers = IbCacheManager().getIbAnswers(uid)!;
        final IbAnswer? ibAnswer = answers
            .firstWhereOrNull((element) => element.questionId == questionId);
        if (ibAnswer != null) {
          theAnswers.add(ibAnswer);
        } else {
          final answer =
              await IbQuestionDbService().querySingleIbAnswer(uid, questionId);
          if (answer == null) {
            continue;
          }
          theAnswers.add(answer);
        }
      }
    }
    return theAnswers;
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

  static Widget leftTimeText(int millsSinceEpoch) {
    final futureDateTime = DateTime.fromMillisecondsSinceEpoch(millsSinceEpoch);
    final diff = futureDateTime.difference(DateTime.now());

    if (diff.isNegative) {
      return const Text(
        'Closed',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: IbConfig.kDescriptionTextSize, color: IbColors.errorRed),
      );
    }

    if (diff.inSeconds < 60) {
      return Text(
        '${diff.inSeconds} sec left',
        style: const TextStyle(
            fontSize: IbConfig.kDescriptionTextSize, color: Colors.deepOrange),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (diff.inMinutes < 60) {
      return Text(
        '${diff.inMinutes} min left',
        style: const TextStyle(
            fontSize: IbConfig.kDescriptionTextSize, color: Colors.orange),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (diff.inHours < 24) {
      return Text(
        '${diff.inHours} hr left',
        style: const TextStyle(
            fontSize: IbConfig.kDescriptionTextSize,
            color: Colors.orangeAccent),
        overflow: TextOverflow.ellipsis,
      );
    }

    return Text(
      '${diff.inDays} d left',
      style: const TextStyle(
          fontSize: IbConfig.kDescriptionTextSize, color: IbColors.accentColor),
      overflow: TextOverflow.ellipsis,
    );
  }

  static Color handleIndicatorColor(double percentageInDecimal) {
    if (percentageInDecimal > 0 && percentageInDecimal <= 0.2) {
      return const Color(0xFFFF0000);
    }

    if (percentageInDecimal > 0.2 && percentageInDecimal <= 0.4) {
      return const Color(0xFFFF6600);
    }

    if (percentageInDecimal > 0.4 && percentageInDecimal <= 0.6) {
      return const Color(0xFFFFB700);
    }

    if (percentageInDecimal > 0.6 && percentageInDecimal <= 0.7) {
      return const Color(0xFFB1E423);
    }

    if (percentageInDecimal >= 0.7 && percentageInDecimal <= 0.9) {
      return const Color(0xFF23E480);
    }

    if (percentageInDecimal > 0.9 && percentageInDecimal <= 1.0) {
      return IbColors.accentColor;
    }
    return IbColors.errorRed;
  }

  static void showInteractiveViewer(
      List<String> urls, Widget widget, BuildContext context) {
    /// show image preview
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        transitionDuration:
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
        barrierColor: Colors.black.withOpacity(0.8),
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) => Stack(
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
              },
              child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(8), child: widget),
            ),
            Positioned(
              right: 8,
              top: 64,
              child: Material(
                color: Colors.transparent,
                child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: const Icon(
                      Icons.cancel,
                      color: IbColors.errorRed,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String statsShortString(int number) {
    if (number < 1000) {
      return number.toString();
    }

    if (number >= 1000 && number < 999999) {
      final double num = number.toDouble() / 1000;
      return '${num.toStringAsFixed(1)}K';
    }

    if (number >= 999999 && number < 9999999) {
      final double num = number.toDouble() / 1000000;
      return '${num.toStringAsFixed(1)}M';
    }

    if (number >= 9999999 && number < 9999999999) {
      final double num = number.toDouble() / 10000000;
      return '${num.toStringAsFixed(1)}B';
    }

    return '10B+';
  }
}
