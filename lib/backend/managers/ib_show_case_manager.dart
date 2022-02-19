import 'package:flutter/material.dart';

class IbShowCaseManager {
  static final IbShowCaseManager _manager = IbShowCaseManager._();
  static final GlobalKey kPickAnswerForQuizKey = GlobalKey();
  static final GlobalKey kPickTagForQuestionKey = GlobalKey();

  factory IbShowCaseManager() => _manager;
  IbShowCaseManager._();
}
