import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../managers/ib_cache_manager.dart';

class IbQuestionResultController extends GetxController {
  final IbQuestionItemController itemController;
  final results = <ResultItemModel>[].obs;
  final isLoading = false.obs;

  IbQuestionResultController(this.itemController);

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
      for (final ibChoice in ibQuestion.choices) {
        final List<IbAnswer> answers = await IbQuestionDbService()
            .queryIbAnswers(
                choiceId: ibChoice.choiceId, questionId: ibQuestion.id);
        final List<ResultItemUserModel> resultItem = [];

        for (final ibAnswer in answers) {
          final IbUser? user;
          if (IbCacheManager().getIbUser(ibAnswer.uid) == null) {
            user = await IbUserDbService().queryIbUser(ibAnswer.uid);
          } else {
            user = IbCacheManager().getIbUser(ibAnswer.uid);
          }

          /// self result item will be in index 0, will add later
          if (user == null) {
            continue;
          }
          final double compScore = await IbUtils.getCompScore(user.id);
          if (user.id == IbUtils.getCurrentUid()) {
            resultItem.insert(
                0,
                ResultItemUserModel(
                    user: user,
                    compScore: compScore,
                    answeredTimestampInMs: ibAnswer.answeredTimeInMs));
            continue;
          }

          resultItem.add(ResultItemUserModel(
              user: user,
              compScore: compScore,
              answeredTimestampInMs: ibAnswer.answeredTimeInMs));
        }

        final int count = itemController.countMap![ibChoice] ?? 0;
        results.add(ResultItemModel(
            list: resultItem.obs, ibChoice: ibChoice, count: count));
      }
      results.sort((a, b) => b.count.compareTo(a.count));
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: "Failed to load results $e", backgroundColor: IbColors.errorRed);
    } finally {
      isLoading.value = false;
    }
  }
}

class ResultItemModel {
  final RxList<ResultItemUserModel> list;
  final IbChoice ibChoice;
  final int count;

  ResultItemModel(
      {required this.list, required this.ibChoice, required this.count});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultItemModel &&
          runtimeType == other.runtimeType &&
          ibChoice == other.ibChoice;

  @override
  int get hashCode => ibChoice.hashCode;
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
