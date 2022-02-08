import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';

import '../services/user_services/ib_question_db_service.dart';
import '../services/user_services/ib_user_db_service.dart';

class IbQuestionStatsController extends GetxController {
  final String questionId;
  final List<IbAnswer> ibAnswers;
  final stats = <IbQuestionStatsItem>[].obs;
  IbQuestion? ibQuestion;
  IbQuestionStatsController(
      {required this.questionId, required this.ibAnswers});
  @override
  Future<void> onInit() async {
    ibQuestion = await IbQuestionDbService().querySingleQuestion(questionId);
    ibAnswers.removeWhere((element) => element.questionId != questionId);
    await initStatsMap();
    super.onInit();
  }

  Future<void> initStatsMap() async {
    if (ibQuestion == null) {
      return;
    }

    for (final ibChoice in ibQuestion!.choices) {
      final List<IbAnswer> tempList = ibAnswers
          .where((element) => element.choiceId == ibChoice.choiceId)
          .toList();

      if (tempList.isNotEmpty) {
        final List<IbUser> userList = [];
        for (final IbAnswer ibAnswer in tempList) {
          final IbUser? user =
              await IbUserDbService().queryIbUser(ibAnswer.uid);

          if (user == null) {
            continue;
          }

          userList.add(user);
        }
        stats.add(IbQuestionStatsItem(choice: ibChoice, users: userList));
      } else {
        continue;
      }
    }
    stats.sort(
        (a, b) => b.users.first.username.compareTo(a.users.first.username));
  }
}

class IbQuestionStatsItem {
  IbChoice choice;
  List<IbUser> users;

  IbQuestionStatsItem({required this.choice, required this.users});
}
