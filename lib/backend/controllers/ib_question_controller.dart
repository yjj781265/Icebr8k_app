import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/my_answered_questions_controller.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// controller for Question tab in Homepage
class IbQuestionController extends GetxController {
  final ibQuestions = <IbQuestion>[].obs;
  final refreshController =
      RefreshController(initialRefreshStatus: RefreshStatus.refreshing);
  final isLoading = true.obs;
  final _myAnsweredQuestionsController =
      Get.find<MyAnsweredQuestionsController>();

  bool hasMore = false;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initQuestions();
  }

  Future<void> _initQuestions() async {
    ibQuestions.clear();

    /// load latest question
    final IbAnswer? answer = await IbQuestionDbService()
        .queryLatestAnsweredQ(IbUtils.getCurrentUid()!);

    if (answer != null) {
      ibQuestions.addAll(await IbQuestionDbService()
          .queryIbQuestions(8, timestamp: answer.askedTimeInMs));
    } else {
      ibQuestions.addAll(await IbQuestionDbService().queryIbQuestions(
        8,
      ));
    }

    /// load old question
    final IbAnswer? oldAnswer = await IbQuestionDbService()
        .queryLastAnsweredQ(IbUtils.getCurrentUid()!);

    if (oldAnswer != null) {
      final list = await IbQuestionDbService().queryIbQuestions(8,
          timestamp: oldAnswer.askedTimeInMs, isGreaterThan: false);
      hasMore = list.isNotEmpty;
      ibQuestions.addAll(list);
    }

    /// load cached question
    await loadCachedQuestions();

    if (ibQuestions.isNotEmpty) {
      ///cached unanswered question to local db
      IbLocalStorageService().updateUnAnsweredIbQList(ibQuestions);
    }
    ibQuestions.shuffle();
    isLoading.value = false;
    refreshController.refreshCompleted(resetFooterState: true);
  }

  Future<void> loadCachedQuestions() async {
    final List<String>? localQuestionIds =
        IbLocalStorageService().getUnAnsweredIbQidList();

    if (localQuestionIds == null || localQuestionIds.isEmpty) {
      return;
    }

    print(
        'IbQuestionController there are ${localQuestionIds.length} local unanswered questions');
    for (final id in localQuestionIds) {
      if (await IbQuestionDbService()
          .isQuestionAnswered(uid: IbUtils.getCurrentUid()!, questionId: id)) {
        IbLocalStorageService().removeUnAnsweredIbQid(id);
        print('IbQuestionController remove $id');
        continue;
      }

      if (!containQuestionId(id)) {
        final q = await IbQuestionDbService().querySingleQuestion(id);
        if (q != null) {
          ibQuestions.addIf(!ibQuestions.contains(q), q);
        }
      }
    }
  }

  bool containQuestionId(String id) {
    for (final q in ibQuestions) {
      if (q.id == id) {
        return true;
      }
    }
    return false;
  }

  int getQuestionIndex(String id) {
    for (int i = 0; i < ibQuestions.length; i++) {
      if (ibQuestions[i].id == id) {
        return i;
      }
    }
    return -1;
  }

  Future<int> getLatestQuestionTimestamp() async {
    if (ibQuestions.isEmpty) {
      /// load latest question
      final IbAnswer? answer = await IbQuestionDbService()
          .queryLatestAnsweredQ(IbUtils.getCurrentUid()!);
      if (answer == null) {
        return 0;
      }
      return answer.askedTimeInMs;
    }
    final List<IbQuestion> temp = [];
    temp.addAll(ibQuestions);
    temp.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    return temp.first.askedTimeInMs;
  }

  Future<void> loadMoreQuestion() async {
    print('IbQuestionController loadMoreQuestion');
    final List<IbQuestion> tempList = [];
    tempList.addAll(ibQuestions);
    tempList.sort((a, b) => b.askedTimeInMs.compareTo(a.askedTimeInMs));
    final list = await IbQuestionDbService().queryIbQuestions(20,
        timestamp: tempList.last.askedTimeInMs, isGreaterThan: false);

    if (list.isEmpty) {
      hasMore = false;
      refreshController.loadNoData();
      return;
    }

    for (final IbQuestion ibQuestion in list) {
      ibQuestions.addIf(!ibQuestions.contains(ibQuestion), ibQuestion);
      IbLocalStorageService().appendUnAnsweredIbQidList(ibQuestion);
    }

    refreshController.loadComplete();
  }

  Future<void> refreshEverything() async {
    final timestamp = await getLatestQuestionTimestamp();
    final list =
        await IbQuestionDbService().queryIbQuestions(8, timestamp: timestamp);
    for (final IbQuestion ibQuestion in list) {
      if (_myAnsweredQuestionsController.retrieveAnswer(ibQuestion.id) ==
          null) {
        ibQuestions.insert(0, ibQuestion);
      }
    }
    refreshController.refreshCompleted();
  }
}
