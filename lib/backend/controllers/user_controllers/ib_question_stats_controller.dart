import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';

class IbQuestionStatsController extends GetxController {
  final List<IbAnswer> ibAnswers;
  final stats = <IbQuestionStatsItem>[].obs;
  final IbQuestion ibQuestion;
  IbQuestionStatsController(
      {required this.ibQuestion, required this.ibAnswers});
  @override
  Future<void> onInit() async {
    ibAnswers.removeWhere((element) => element.questionId != ibQuestion.id);
    await initStatsMap();
    super.onInit();
  }

  Future<void> initStatsMap() async {
    for (final ibChoice in ibQuestion.choices) {
      final List<IbAnswer> tempList = ibAnswers
          .where((element) => element.choiceId == ibChoice.choiceId)
          .toList();

      if (tempList.isNotEmpty) {
        final List<IbUser> userList = [];
        for (final IbAnswer ibAnswer in tempList) {
          final IbUser? user;
          if (IbCacheManager().getIbUser(ibAnswer.uid) == null) {
            user = await IbUserDbService().queryIbUser(ibAnswer.uid);
          } else {
            user = IbCacheManager().getIbUser(ibAnswer.uid);
          }

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
