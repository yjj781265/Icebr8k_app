import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../services/user_services/ib_question_db_service.dart';
import 'ib_question_item_controller.dart';

class QuestionResultDetailPageController extends GetxController {
  final IbQuestionItemController itemController;
  final results = <ResultItemUserModel>[].obs;
  final IbChoice ibChoice;
  final isLoading = false.obs;

  QuestionResultDetailPageController(
      {required this.itemController, required this.ibChoice});

  @override
  Future<void> onInit() async {
    super.onInit();
    initResultMap();
  }

  Future<void> initResultMap() async {
    isLoading.value = true;
    results.clear();
    final ibQuestion = itemController.rxIbQuestion.value;
    try {
      await IbQuestionDbService().queryIbAnswers(
          choiceId: ibChoice.choiceId,
          questionId: itemController.rxIbQuestion.value.id);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: "Failed to load results $e", backgroundColor: IbColors.errorRed);
    } finally {
      isLoading.value = false;
    }
  }
}

class ResultItemUserModel {
  IbUser user;
  double compScore;
  int answeredTimestampInMs;

  ResultItemUserModel(
      {required this.user,
      required this.compScore,
      required this.answeredTimestampInMs});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultItemUserModel &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}
