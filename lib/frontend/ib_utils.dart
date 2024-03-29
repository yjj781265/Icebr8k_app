import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icebr8k/backend/controllers/user_controllers/answered_question_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/home_tab_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_settings.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../backend/controllers/user_controllers/asked_questions_controller.dart';
import '../backend/controllers/user_controllers/auth_controller.dart';
import '../backend/models/ib_question.dart';
import '../backend/services/user_services/ib_local_data_service.dart';
import '../backend/services/user_services/ib_question_db_service.dart';
import 'ib_config.dart';

class IbUtils {
  static final IbUtils utils = IbUtils._();
  factory IbUtils() {
    return utils;
  }
  IbUtils._();

  void offAll(Widget page,
      {Transition transition = Transition.native, Bindings? binding}) {
    Get.offAll(() => page, transition: transition, binding: binding);
  }

  void toPage(Widget page,
      {Transition transition = Transition.native, Bindings? binding}) {
    Get.to(() => page, transition: transition, binding: binding);
  }

  void showDialog(Widget dialog, {bool barrierDismissible = true}) {
    Get.dialog(dialog, barrierDismissible: barrierDismissible);
  }

  void closeAllSnackbars() {
    Get.closeAllSnackbars();
  }

  void hideKeyboard() => FocusManager.instance.primaryFocus?.unfocus();

  bool isOver13(DateTime dateTime) {
    final bool isOver13 =
        DateTime.now().difference(dateTime).inDays > IbConfig.kAgeLimitInDays;
    return isOver13;
  }

  void changeStatusBarColor() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(

          ///for android
          statusBarIconBrightness:
              IbLocalDataService().retrieveBoolValue(StorageKey.isDarkModeBool)
                  ? Brightness.light
                  : Brightness.dark,

          ///for IOS
          statusBarBrightness:
              IbLocalDataService().retrieveBoolValue(StorageKey.isDarkModeBool)
                  ? Brightness.dark
                  : Brightness.light,
          statusBarColor:
              IbLocalDataService().retrieveBoolValue(StorageKey.isDarkModeBool)
                  ? Colors.black
                  : IbColors.lightBlue),
    );
  }

  int calculateAge(int timestampInMs) {
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

  Future<CroppedFile?> showImageCropper(String filePath,
      {CropStyle cropStyle = CropStyle.circle,
      List<CropAspectRatioPreset> ratios = const [
        CropAspectRatioPreset.original,
      ],
      double? height,
      double? width,
      bool resetAspectRatioEnabled = true,
      CropAspectRatioPreset initAspectRatio = CropAspectRatioPreset.original,
      bool lockAspectRatio = false,
      double minimumAspectRatio = 1.0}) async {
    return ImageCropper().cropImage(
      compressFormat: ImageCompressFormat.png,
      sourcePath: filePath,
      cropStyle: cropStyle,
      aspectRatioPresets: ratios,
      uiSettings: [
        AndroidUiSettings(
            toolbarColor: IbColors.darkPrimaryColor,
            toolbarTitle: 'Image Cropper',
            initAspectRatio: initAspectRatio,
            lockAspectRatio: lockAspectRatio),
        IOSUiSettings(
          rectHeight: height,
          rectWidth: width,
          title: 'Image Cropper',
        )
      ],
    );
  }

  String getUniqueId() {
    return const Uuid().v4();
  }

  String readableDateTime(DateTime _dateTime, {bool showTime = false}) {
    if (showTime) {
      return '${DateFormat('hh:mm aa').format(_dateTime.toLocal())} ${getSuffixDateTimeString(_dateTime.toLocal())}';
    }
    final f = DateFormat('MM/dd/yyyy');
    return f.format(_dateTime.toLocal());
  }

  String getAgoDateTimeString(DateTime _dateTime) {
    final Duration diffDt = DateTime.now().difference(_dateTime);
    if (diffDt.inSeconds <= 0) {
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

  String getDistanceString(double distanceInMeter, {bool isMetric = false}) {
    final double foot = 3.28084 * distanceInMeter;
    if (foot < 528) {
      return '0.1 mi';
    }
    return '${(foot / 5280).toPrecision(1)} mi';
  }

  /// Returns the difference (in full days) between the provided date and today.
  int _calculateDifference(DateTime date) {
    final DateTime now = DateTime.now().toLocal();
    return date.difference(now).inDays;
  }

  String getStatsString(int num) {
    if (num < 10000) {
      return num.toString();
    }

    final String d = (num.toDouble() / 1000).toStringAsFixed(0);
    return '${d}k';
  }

  String getSuffixDateTimeString(DateTime _dateTime) {
    if (_calculateDifference(_dateTime.toLocal()) == 0) {
      return '';
    }

    if (_calculateDifference(_dateTime.toLocal()) == 1) {
      return 'tomorrow';
    }

    if (_calculateDifference(_dateTime.toLocal()) == -1) {
      return 'yesterday';
    }

    final Duration diffDt =
        DateTime.now().toLocal().difference(_dateTime.toLocal());
    if (diffDt.inDays < 365) {
      final DateFormat formatter = DateFormat('MM/dd');
      final String formatted = formatter.format(_dateTime.toLocal());
      return formatted;
    } else {
      final DateFormat formatter = DateFormat('MM/dd/yyyy');
      final String formatted = formatter.format(_dateTime.toLocal());
      return formatted;
    }
  }

  Future<bool> isOverDailyPollLimit() async {
    if (isPremiumMember()) {
      return false;
    }

    final int count =
        await IbQuestionDbService().queryDailyCurrentUserPollsCount();
    return count >= IbConfig.kDailyPollLimit;
  }

  String getChatTabDateString(DateTime _dateTime) {
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

  String? getCurrentUid() {
    if (Get.find<AuthController>().firebaseUser == null) {
      return null;
    }
    return Get.find<AuthController>().firebaseUser!.uid;
  }

  IbUser? getCurrentIbUser() {
    if (!Get.isRegistered<MainPageController>()) {
      return null;
    }
    return Get.find<MainPageController>().rxCurrentIbUser.value;
  }

  /// return current IbUser friend ids what are not in block list
  List<String> getCurrentIbUserUnblockedFriendsId() {
    if (getCurrentIbUser() == null) {
      return [];
    }
    return getCurrentIbUser()!
        .friendUids
        .where((element) =>
            !getCurrentIbUser()!.blockedFriendUids.contains(element))
        .toList();
  }

  /// return current IbUser circle chat items
  List<ChatTabItem> getCircleItems() {
    if (!Get.isRegistered<SocialTabController>()) {
      return [];
    }
    final circleItems =
        List<ChatTabItem>.from(Get.find<SocialTabController>().circles);
    return circleItems;
  }

  /// return current IbUser all chat items
  List<ChatTabItem> getAllChatTabItems() {
    if (!Get.isRegistered<SocialTabController>()) {
      return [];
    }
    final circleItems =
        List<ChatTabItem>.from(Get.find<SocialTabController>().circles);
    final oneToOneItems =
        List<ChatTabItem>.from(Get.find<SocialTabController>().oneToOneChats);
    oneToOneItems.addAll(circleItems);
    final allItems = oneToOneItems.toSet().toList();
    allItems.sort((a, b) => (a.title).compareTo(b.title));
    return allItems;
  }

  /// return current ib google fonts
  List<TextStyle> getIbFonts(TextStyle style) {
    return [
      GoogleFonts.openSans(textStyle: style),
      GoogleFonts.robotoSlab(textStyle: style),
      GoogleFonts.breeSerif(textStyle: style),
      GoogleFonts.comicNeue(textStyle: style),
      GoogleFonts.nothingYouCouldDo(textStyle: style),
      GoogleFonts.shadowsIntoLight(textStyle: style),
      GoogleFonts.abrilFatface(textStyle: style),
      GoogleFonts.caveat(textStyle: style),
      GoogleFonts.cormorantGaramond(textStyle: style),
      GoogleFonts.theGirlNextDoor(textStyle: style),
    ];
  }

  User? getCurrentFbUser() {
    if (Get.find<AuthController>().firebaseUser == null) {
      return null;
    }
    return Get.find<AuthController>().firebaseUser;
  }

  void showPersistentSnackBar() {}

  void showSimpleSnackBar(
      {required String msg,
      required Color backgroundColor,
      Duration duration = const Duration(seconds: 2),
      bool isPersistent = false}) {
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
      duration: isPersistent ? const Duration(days: 999) : duration,
      backgroundColor: Get.context == null
          ? IbColors.lightBlue
          : Theme.of(Get.context!).backgroundColor,
      messageText: Text(
        msg,
        style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
      ),
    ));
  }

  Future<double> getCompScore(
      {required String uid, bool isRefresh = false}) async {
    final List<IbAnswer> uid1QuestionAnswers = [];
    final List<IbAnswer> uid2QuestionAnswers = [];
    if (IbCacheManager().getIbAnswers(getCurrentUid()!) == null || isRefresh) {
      final tempList =
          await IbQuestionDbService().queryUserAnswers(getCurrentUid()!);
      IbCacheManager()
          .cacheIbAnswers(uid: getCurrentUid()!, ibAnswers: tempList);
      uid1QuestionAnswers.addAll(tempList);
      print('refresh list1');
    } else {
      uid1QuestionAnswers
          .addAll(IbCacheManager().getIbAnswers(getCurrentUid()!)!);
    }

    if (IbCacheManager().getIbAnswers(uid) == null || isRefresh) {
      final tempList = await IbQuestionDbService().queryUserAnswers(uid);
      IbCacheManager().cacheIbAnswers(uid: uid, ibAnswers: tempList);
      uid2QuestionAnswers.addAll(tempList);
      print('refresh list2');
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

  Future<List<String>> getCommonAnswerQuestionIds(
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

  Future<List<String>> getUncommonAnswerQuestionIds(
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

  Future<List<IbAnswer>> getIbAnswersForDifferentUsers(
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
        IbCacheManager().cacheSingleIbAnswer(uid: uid, ibAnswer: answer);
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
          IbCacheManager().cacheSingleIbAnswer(uid: uid, ibAnswer: answer);
        }
      }
    }
    return theAnswers;
  }

  Color getRandomColor() {
    final Random random = Random();
    final List<Color> _colors = [
      IbColors.primaryColor,
      IbColors.accentColor,
      IbColors.lightGrey,
      Colors.redAccent,
      Colors.deepOrange,
      Colors.cyanAccent,
      Colors.lightBlueAccent,
      Colors.purpleAccent,
    ];
    return _colors[random.nextInt(_colors.length)];
  }

  Widget leftTimeText(int millsSinceEpoch) {
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

  Color handleIndicatorColor(double percentageInDecimal) {
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

  void showInteractiveViewer(
      List<String> urls, Widget widget, BuildContext context) {
    /// show image preview
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
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

  IbSettings getCurrentUserSettings() {
    if (getCurrentIbUser() == null || getCurrentIbUser()!.settings == null) {
      return IbSettings();
    } else {
      return getCurrentIbUser()!.settings!;
    }
  }

  String statsShortString(int number) {
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

  Widget handleQuestionType(IbQuestion question,
      {bool uniqueTag = false,
      List<IbAnswer> ibAnswers = const [],
      String? customTag,
      bool expanded = false,
      bool isSample = false,
      bool isShowCase = false,
      IbQuestionItemController? itemController}) {
    if (itemController == null) {
      final tag = uniqueTag ? (customTag ?? getUniqueId()) : question.id;
      final IbQuestionItemController controller = Get.put(
          IbQuestionItemController(
              ibAnswers: ibAnswers,
              isShowCase: isShowCase.obs,
              rxIbQuestion: question.obs,
              rxIsExpanded: expanded.obs,
              rxIsSample: isSample.obs),
          tag: tag);
      if (question.questionType == QuestionType.multipleChoice ||
          question.questionType == QuestionType.multipleChoicePic) {
        return IbMcQuestionCard(
          controller,
        );
      }

      return IbScQuestionCard(controller);
    }

    if (question.questionType == QuestionType.multipleChoice ||
        question.questionType == QuestionType.multipleChoicePic) {
      return IbMcQuestionCard(itemController);
    }

    return IbScQuestionCard(itemController);
  }

  void masterDeleteSingleQuestion(IbQuestion ibQuestion) {
    if (Get.isRegistered<HomeTabController>()) {
      Get.find<HomeTabController>()
          .forYourList
          .removeWhere((element) => element.id == ibQuestion.id);
      Get.find<HomeTabController>()
          .trendingList
          .removeWhere((element) => element.id == ibQuestion.id);
      Get.find<HomeTabController>()
          .newestList
          .removeWhere((element) => element.id == ibQuestion.id);
    }

    if (Get.isRegistered<AnsweredQuestionController>()) {
      Get.find<AnsweredQuestionController>()
          .answeredQs
          .removeWhere((element) => element.id == ibQuestion.id);
    }

    if (Get.isRegistered<AskedQuestionsController>(tag: getCurrentUid())) {
      Get.find<AskedQuestionsController>(tag: getCurrentUid())
          .createdQuestions
          .removeWhere((element) => element.id == ibQuestion.id);
    }

    for (final tag in ibQuestion.tags) {
      if (Get.isRegistered<TagPageController>(tag: tag)) {
        Get.find<TagPageController>(tag: tag)
            .ibQuestions
            .removeWhere((element) => element.id == ibQuestion.id);
      }
    }
  }

  bool checkFeatureIsLocked() {
    final bool isLocked = Get.find<HomeTabController>().isLocked.value;
    print(isLocked);
    if (isLocked) {
      Get.dialog(
          const IbDialog(
            title: 'Feature Locked',
            content: Text.rich(
              TextSpan(
                  text: "Please answer all polls from Icebr8k in ",
                  children: [
                    TextSpan(
                        text: 'For You',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: ' page in order to unlock other features')
                  ]),
              textAlign: TextAlign.start,
            ),
            subtitle: '',
            showNegativeBtn: false,
          ),
          barrierDismissible: false);
    }
    return isLocked;
  }

  bool isPremiumMember() {
    if (getCurrentIbUser() == null) {
      return false;
    }
    return getCurrentIbUser()!.isPremium || getCurrentIbUser()!.isMasterPremium;
  }
}
