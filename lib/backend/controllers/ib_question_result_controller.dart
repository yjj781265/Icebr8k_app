import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbQuestionResultController extends GetxController {
  final IbQuestionItemController itemController;
  final resultMap = <IbChoice, RxList<ResultItemModel>>{}.obs;
  final isLoading = false.obs;

  IbQuestionResultController(this.itemController);

  @override
  Future<void> onInit() async {
    super.onInit();
    initResultMap();
  }

  Future<void> initResultMap() async {
    isLoading.value = true;
    resultMap.clear();
    final ibQuestion = itemController.rxIbQuestion.value;
    try {
      for (final ibChoice in ibQuestion.choices) {
        final List<IbAnswer> answers = await IbQuestionDbService()
            .queryIbAnswers(
                choiceId: ibChoice.choiceId, questionId: ibQuestion.id);
        final List<ResultItemModel> resultItem = [];

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
                0, ResultItemModel(user: user, compScore: compScore));
            continue;
          }
          resultItem.add(ResultItemModel(user: user, compScore: compScore));
        }

        resultMap[ibChoice] = resultItem.obs;
      }
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: "Failed to load results $e", backgroundColor: IbColors.errorRed);
    } finally {
      isLoading.value = false;
    }
  }
}

class ResultItemModel {
  IbUser user;
  double compScore;

  ResultItemModel({required this.user, required this.compScore});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultItemModel &&
          runtimeType == other.runtimeType &&
          user == other.user;

  @override
  int get hashCode => user.hashCode;
}
