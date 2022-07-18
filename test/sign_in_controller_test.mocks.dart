// Mocks generated by Mockito 5.2.0 from annotations
// in icebr8k/test/sign_in_controller_test.dart.
// Do not manually edit this file.

import 'dart:async' as _i10;
import 'dart:ui' as _i2;

import 'package:firebase_auth/firebase_auth.dart' as _i17;
import 'package:flutter/material.dart' as _i3;
import 'package:get/get.dart' as _i5;
import 'package:icebr8k/backend/controllers/user_controllers/auth_controller.dart'
    as _i16;
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart'
    as _i15;
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart'
    as _i12;
import 'package:icebr8k/backend/models/ib_answer.dart' as _i13;
import 'package:icebr8k/backend/models/ib_question.dart' as _i14;
import 'package:icebr8k/backend/models/ib_settings.dart' as _i4;
import 'package:icebr8k/backend/services/user_services/ib_auth_service.dart'
    as _i9;
import 'package:icebr8k/backend/services/user_services/ib_db_status_service.dart'
    as _i7;
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart'
    as _i8;
import 'package:icebr8k/frontend/ib_utils.dart' as _i6;
import 'package:image_cropper/image_cropper.dart' as _i11;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types

class _FakeColor_0 extends _i1.Fake implements _i2.Color {}

class _FakeWidget_1 extends _i1.Fake implements _i3.Widget {
  @override
  String toString({_i3.DiagnosticLevel? minLevel = _i3.DiagnosticLevel.info}) =>
      super.toString();
}

class _FakeIbSettings_2 extends _i1.Fake implements _i4.IbSettings {}

class _FakeRxBool_3 extends _i1.Fake implements _i5.RxBool {}

class _FakeIbUtils_4 extends _i1.Fake implements _i6.IbUtils {}

class _FakeIbDbStatusService_5 extends _i1.Fake
    implements _i7.IbDbStatusService {}

class _FakeIbLocalDataService_6 extends _i1.Fake
    implements _i8.IbLocalDataService {}

class _FakeIbAuthService_7 extends _i1.Fake implements _i9.IbAuthService {}

class _FakeInternalFinalCallback_8<T> extends _i1.Fake
    implements _i5.InternalFinalCallback<T> {}

/// A class which mocks [IbUtils].
///
/// See the documentation for Mockito's code generation for more information.
class MockIbUtils extends _i1.Mock implements _i6.IbUtils {
  MockIbUtils() {
    _i1.throwOnMissingStub(this);
  }

  @override
  void offAll(_i3.Widget? page,
          {_i5.Transition? transition = _i5.Transition.native,
          _i5.Bindings? binding}) =>
      super.noSuchMethod(
          Invocation.method(
              #offAll, [page], {#transition: transition, #binding: binding}),
          returnValueForMissingStub: null);
  @override
  void toPage(_i3.Widget? page,
          {_i5.Transition? transition = _i5.Transition.native,
          _i5.Bindings? binding}) =>
      super.noSuchMethod(
          Invocation.method(
              #toPage, [page], {#transition: transition, #binding: binding}),
          returnValueForMissingStub: null);
  @override
  void showDialog(_i3.Widget? dialog, {bool? barrierDismissible = true}) =>
      super.noSuchMethod(
          Invocation.method(
              #showDialog, [dialog], {#barrierDismissible: barrierDismissible}),
          returnValueForMissingStub: null);
  @override
  void closeAllSnackbars() =>
      super.noSuchMethod(Invocation.method(#closeAllSnackbars, []),
          returnValueForMissingStub: null);
  @override
  void hideKeyboard() =>
      super.noSuchMethod(Invocation.method(#hideKeyboard, []),
          returnValueForMissingStub: null);
  @override
  bool isOver13(DateTime? dateTime) =>
      (super.noSuchMethod(Invocation.method(#isOver13, [dateTime]),
          returnValue: false) as bool);
  @override
  void changeStatusBarColor() =>
      super.noSuchMethod(Invocation.method(#changeStatusBarColor, []),
          returnValueForMissingStub: null);
  @override
  int calculateAge(int? timestampInMs) =>
      (super.noSuchMethod(Invocation.method(#calculateAge, [timestampInMs]),
          returnValue: 0) as int);
  @override
  _i10.Future<_i11.CroppedFile?> showImageCropper(String? filePath,
          {_i11.CropStyle? cropStyle = _i11.CropStyle.circle,
          List<_i11.CropAspectRatioPreset>? ratios = const [
            _i11.CropAspectRatioPreset.original
          ],
          double? height,
          double? width,
          bool? resetAspectRatioEnabled = true,
          _i11.CropAspectRatioPreset? initAspectRatio =
              _i11.CropAspectRatioPreset.original,
          bool? lockAspectRatio = false,
          double? minimumAspectRatio = 1.0}) =>
      (super.noSuchMethod(
              Invocation.method(#showImageCropper, [
                filePath
              ], {
                #cropStyle: cropStyle,
                #ratios: ratios,
                #height: height,
                #width: width,
                #resetAspectRatioEnabled: resetAspectRatioEnabled,
                #initAspectRatio: initAspectRatio,
                #lockAspectRatio: lockAspectRatio,
                #minimumAspectRatio: minimumAspectRatio
              }),
              returnValue: Future<_i11.CroppedFile?>.value())
          as _i10.Future<_i11.CroppedFile?>);
  @override
  String getUniqueId() =>
      (super.noSuchMethod(Invocation.method(#getUniqueId, []), returnValue: '')
          as String);
  @override
  String readableDateTime(DateTime? _dateTime, {bool? showTime = false}) =>
      (super.noSuchMethod(
          Invocation.method(
              #readableDateTime, [_dateTime], {#showTime: showTime}),
          returnValue: '') as String);
  @override
  String getAgoDateTimeString(DateTime? _dateTime) =>
      (super.noSuchMethod(Invocation.method(#getAgoDateTimeString, [_dateTime]),
          returnValue: '') as String);
  @override
  String getDistanceString(double? distanceInMeter, {bool? isMetric = false}) =>
      (super.noSuchMethod(
          Invocation.method(
              #getDistanceString, [distanceInMeter], {#isMetric: isMetric}),
          returnValue: '') as String);
  @override
  String getStatsString(int? num) =>
      (super.noSuchMethod(Invocation.method(#getStatsString, [num]),
          returnValue: '') as String);
  @override
  String getSuffixDateTimeString(DateTime? _dateTime) => (super.noSuchMethod(
      Invocation.method(#getSuffixDateTimeString, [_dateTime]),
      returnValue: '') as String);
  @override
  _i10.Future<bool> isOverDailyPollLimit() =>
      (super.noSuchMethod(Invocation.method(#isOverDailyPollLimit, []),
          returnValue: Future<bool>.value(false)) as _i10.Future<bool>);
  @override
  String getChatTabDateString(DateTime? _dateTime) =>
      (super.noSuchMethod(Invocation.method(#getChatTabDateString, [_dateTime]),
          returnValue: '') as String);
  @override
  List<String> getCurrentIbUserUnblockedFriendsId() => (super.noSuchMethod(
      Invocation.method(#getCurrentIbUserUnblockedFriendsId, []),
      returnValue: <String>[]) as List<String>);
  @override
  List<_i12.ChatTabItem> getCircleItems() =>
      (super.noSuchMethod(Invocation.method(#getCircleItems, []),
          returnValue: <_i12.ChatTabItem>[]) as List<_i12.ChatTabItem>);
  @override
  List<_i12.ChatTabItem> getAllChatTabItems() =>
      (super.noSuchMethod(Invocation.method(#getAllChatTabItems, []),
          returnValue: <_i12.ChatTabItem>[]) as List<_i12.ChatTabItem>);
  @override
  List<_i3.TextStyle> getIbFonts(_i3.TextStyle? style) =>
      (super.noSuchMethod(Invocation.method(#getIbFonts, [style]),
          returnValue: <_i3.TextStyle>[]) as List<_i3.TextStyle>);
  @override
  void showPersistentSnackBar() =>
      super.noSuchMethod(Invocation.method(#showPersistentSnackBar, []),
          returnValueForMissingStub: null);
  @override
  void showSimpleSnackBar(
          {String? msg,
          _i2.Color? backgroundColor,
          Duration? duration = const Duration(seconds: 2),
          bool? isPersistent = false}) =>
      super.noSuchMethod(
          Invocation.method(#showSimpleSnackBar, [], {
            #msg: msg,
            #backgroundColor: backgroundColor,
            #duration: duration,
            #isPersistent: isPersistent
          }),
          returnValueForMissingStub: null);
  @override
  _i10.Future<double> getCompScore({String? uid, bool? isRefresh = false}) =>
      (super.noSuchMethod(
          Invocation.method(
              #getCompScore, [], {#uid: uid, #isRefresh: isRefresh}),
          returnValue: Future<double>.value(0.0)) as _i10.Future<double>);
  @override
  _i10.Future<List<String>> getCommonAnswerQuestionIds(
          {String? uid, bool? isRefresh = false}) =>
      (super.noSuchMethod(
              Invocation.method(#getCommonAnswerQuestionIds, [],
                  {#uid: uid, #isRefresh: isRefresh}),
              returnValue: Future<List<String>>.value(<String>[]))
          as _i10.Future<List<String>>);
  @override
  _i10.Future<List<String>> getUncommonAnswerQuestionIds(
          {String? uid, bool? isRefresh = false}) =>
      (super.noSuchMethod(
              Invocation.method(#getUncommonAnswerQuestionIds, [],
                  {#uid: uid, #isRefresh: isRefresh}),
              returnValue: Future<List<String>>.value(<String>[]))
          as _i10.Future<List<String>>);
  @override
  _i10.Future<List<_i13.IbAnswer>> getIbAnswersForDifferentUsers(
          {List<String>? uids, String? questionId, bool? isRefresh = false}) =>
      (super.noSuchMethod(
              Invocation.method(#getIbAnswersForDifferentUsers, [], {
                #uids: uids,
                #questionId: questionId,
                #isRefresh: isRefresh
              }),
              returnValue: Future<List<_i13.IbAnswer>>.value(<_i13.IbAnswer>[]))
          as _i10.Future<List<_i13.IbAnswer>>);
  @override
  _i2.Color getRandomColor() =>
      (super.noSuchMethod(Invocation.method(#getRandomColor, []),
          returnValue: _FakeColor_0()) as _i2.Color);
  @override
  _i3.Widget leftTimeText(int? millsSinceEpoch) =>
      (super.noSuchMethod(Invocation.method(#leftTimeText, [millsSinceEpoch]),
          returnValue: _FakeWidget_1()) as _i3.Widget);
  @override
  _i2.Color handleIndicatorColor(double? percentageInDecimal) =>
      (super.noSuchMethod(
          Invocation.method(#handleIndicatorColor, [percentageInDecimal]),
          returnValue: _FakeColor_0()) as _i2.Color);
  @override
  void showInteractiveViewer(
          List<String>? urls, _i3.Widget? widget, _i3.BuildContext? context) =>
      super.noSuchMethod(
          Invocation.method(#showInteractiveViewer, [urls, widget, context]),
          returnValueForMissingStub: null);
  @override
  _i4.IbSettings getCurrentUserSettings() =>
      (super.noSuchMethod(Invocation.method(#getCurrentUserSettings, []),
          returnValue: _FakeIbSettings_2()) as _i4.IbSettings);
  @override
  String statsShortString(int? number) =>
      (super.noSuchMethod(Invocation.method(#statsShortString, [number]),
          returnValue: '') as String);
  @override
  _i3.Widget handleQuestionType(_i14.IbQuestion? question,
          {bool? uniqueTag = false,
          List<_i13.IbAnswer>? ibAnswers = const [],
          String? customTag,
          bool? expanded = false,
          bool? isSample = false,
          bool? isShowCase = false,
          _i15.IbQuestionItemController? itemController}) =>
      (super.noSuchMethod(
          Invocation.method(#handleQuestionType, [
            question
          ], {
            #uniqueTag: uniqueTag,
            #ibAnswers: ibAnswers,
            #customTag: customTag,
            #expanded: expanded,
            #isSample: isSample,
            #isShowCase: isShowCase,
            #itemController: itemController
          }),
          returnValue: _FakeWidget_1()) as _i3.Widget);
  @override
  void masterDeleteSingleQuestion(_i14.IbQuestion? ibQuestion) =>
      super.noSuchMethod(
          Invocation.method(#masterDeleteSingleQuestion, [ibQuestion]),
          returnValueForMissingStub: null);
  @override
  bool checkFeatureIsLocked() =>
      (super.noSuchMethod(Invocation.method(#checkFeatureIsLocked, []),
          returnValue: false) as bool);
  @override
  bool isPremiumMember() =>
      (super.noSuchMethod(Invocation.method(#isPremiumMember, []),
          returnValue: false) as bool);
}

/// A class which mocks [AuthController].
///
/// See the documentation for Mockito's code generation for more information.
class MockAuthController extends _i1.Mock implements _i16.AuthController {
  MockAuthController() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.RxBool get isInitializing =>
      (super.noSuchMethod(Invocation.getter(#isInitializing),
          returnValue: _FakeRxBool_3()) as _i5.RxBool);
  @override
  _i5.RxBool get isSigningIn =>
      (super.noSuchMethod(Invocation.getter(#isSigningIn),
          returnValue: _FakeRxBool_3()) as _i5.RxBool);
  @override
  _i5.RxBool get isSigningUp =>
      (super.noSuchMethod(Invocation.getter(#isSigningUp),
          returnValue: _FakeRxBool_3()) as _i5.RxBool);
  @override
  bool get isAnalyticsEnabled =>
      (super.noSuchMethod(Invocation.getter(#isAnalyticsEnabled),
          returnValue: false) as bool);
  @override
  set isAnalyticsEnabled(bool? _isAnalyticsEnabled) => super.noSuchMethod(
      Invocation.setter(#isAnalyticsEnabled, _isAnalyticsEnabled),
      returnValueForMissingStub: null);
  @override
  set firebaseUser(_i17.User? _firebaseUser) =>
      super.noSuchMethod(Invocation.setter(#firebaseUser, _firebaseUser),
          returnValueForMissingStub: null);
  @override
  _i6.IbUtils get ibUtils => (super.noSuchMethod(Invocation.getter(#ibUtils),
      returnValue: _FakeIbUtils_4()) as _i6.IbUtils);
  @override
  _i7.IbDbStatusService get ibDbStatusService =>
      (super.noSuchMethod(Invocation.getter(#ibDbStatusService),
          returnValue: _FakeIbDbStatusService_5()) as _i7.IbDbStatusService);
  @override
  _i8.IbLocalDataService get ibLocalDataService =>
      (super.noSuchMethod(Invocation.getter(#ibLocalDataService),
          returnValue: _FakeIbLocalDataService_6()) as _i8.IbLocalDataService);
  @override
  _i9.IbAuthService get ibAuthService =>
      (super.noSuchMethod(Invocation.getter(#ibAuthService),
          returnValue: _FakeIbAuthService_7()) as _i9.IbAuthService);
  @override
  _i5.InternalFinalCallback<void> get onStart =>
      (super.noSuchMethod(Invocation.getter(#onStart),
              returnValue: _FakeInternalFinalCallback_8<void>())
          as _i5.InternalFinalCallback<void>);
  @override
  _i5.InternalFinalCallback<void> get onDelete =>
      (super.noSuchMethod(Invocation.getter(#onDelete),
              returnValue: _FakeInternalFinalCallback_8<void>())
          as _i5.InternalFinalCallback<void>);
  @override
  bool get initialized =>
      (super.noSuchMethod(Invocation.getter(#initialized), returnValue: false)
          as bool);
  @override
  bool get isClosed =>
      (super.noSuchMethod(Invocation.getter(#isClosed), returnValue: false)
          as bool);
  @override
  void onInit() => super.noSuchMethod(Invocation.method(#onInit, []),
      returnValueForMissingStub: null);
  @override
  void onClose() => super.noSuchMethod(Invocation.method(#onClose, []),
      returnValueForMissingStub: null);
  @override
  _i10.Future<void> setUpAnalytics() => (super.noSuchMethod(
      Invocation.method(#setUpAnalytics, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i10.Future<void>);
  @override
  _i10.Future<void> signInViaEmail(
          {String? email, String? password, bool? rememberEmail}) =>
      (super.noSuchMethod(
              Invocation.method(#signInViaEmail, [], {
                #email: email,
                #password: password,
                #rememberEmail: rememberEmail
              }),
              returnValue: Future<void>.value(),
              returnValueForMissingStub: Future<void>.value())
          as _i10.Future<void>);
  @override
  _i10.Future<dynamic> signUpViaEmail(String? email, String? password) =>
      (super.noSuchMethod(Invocation.method(#signUpViaEmail, [email, password]),
          returnValue: Future<dynamic>.value()) as _i10.Future<dynamic>);
  @override
  _i10.Future<void> navigateToCorrectPage() => (super.noSuchMethod(
      Invocation.method(#navigateToCorrectPage, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i10.Future<void>);
  @override
  _i10.Future<void> resetPassword(String? email) => (super.noSuchMethod(
      Invocation.method(#resetPassword, [email]),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i10.Future<void>);
  @override
  _i10.Future<void> signOut() => (super.noSuchMethod(
      Invocation.method(#signOut, []),
      returnValue: Future<void>.value(),
      returnValueForMissingStub: Future<void>.value()) as _i10.Future<void>);
  @override
  void onReady() => super.noSuchMethod(Invocation.method(#onReady, []),
      returnValueForMissingStub: null);
  @override
  void $configureLifeCycle() =>
      super.noSuchMethod(Invocation.method(#$configureLifeCycle, []),
          returnValueForMissingStub: null);
}
