import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbQuestionItemController extends GetxController {
  final IbQuestion ibQuestion;
  final isAnswered = false.obs;
  final isAnswering = false.obs;
  final isLoading = false.obs;

  ///user who created the question
  IbUser? ibUser;

  /// voted timestamp in dateTime
  final votedDateTime = DateTime.now().obs;
  final title = ''.obs;
  final subtitle = ''.obs;
  final avatarUrl = ''.obs;
  bool isExpandable;
  bool isSample;
  RxBool isExpanded = true.obs;

  /// if user already answered, pass the answer here
  IbAnswer? ibAnswer;
  final totalPolled = 0.obs;
  final selectedChoice = ''.obs;
  final resultMap = <String, double>{}.obs;

  IbQuestionItemController(
      {required this.ibQuestion,
      required this.isExpanded,
      this.isExpandable = false,
      this.isSample = false,
      this.ibAnswer});

  @override
  Future<void> onReady() async {
    /// check if user has already answered this question
    ibAnswer ??= await IbQuestionDbService()
        .queryIbAnswer(IbUtils.getCurrentUid()!, ibQuestion.id);

    if (ibAnswer != null) {
      votedDateTime.value =
          DateTime.fromMillisecondsSinceEpoch(ibAnswer!.timeStampInMs);
    }

    selectedChoice.value = ibAnswer == null ? '' : ibAnswer!.answer;
    isAnswered.value = ibAnswer != null;

    /// query question author user info
    ibUser = await IbUserDbService().queryIbUser(ibQuestion.creatorId);

    if (ibUser != null) {
      /// populate title ..etc
      title.value = ibUser!.username;
      subtitle.value = IbUtils.getAgoDateTimeString(
          DateTime.fromMillisecondsSinceEpoch(ibQuestion.createdTimeInMs));
      avatarUrl.value = ibUser!.avatarUrl;
    }

    /// populate result map
    await calculateResult();
    isLoading.value = false;
    super.onReady();
  }

  Future<void> calculateResult() async {
    totalPolled.value =
        await IbQuestionDbService().queryPollSize(ibQuestion.id);
    if (ibQuestion.questionType == IbQuestion.kMultipleChoice) {
      for (final String choice in ibQuestion.choices) {
        final int size = await IbQuestionDbService()
            .querySpecificAnswerPollSize(
                questionId: ibQuestion.id, answer: choice);
        final double result = (size.toDouble()) / (totalPolled.toDouble());
        resultMap[choice] = result;
      }

      ///scale question has answers from 1 to 5
    } else if (ibQuestion.questionType == IbQuestion.kScale) {
      for (int i = 1; i < 5; i++) {
        final int size = await IbQuestionDbService()
            .querySpecificAnswerPollSize(
                questionId: ibQuestion.id, answer: i.toString());
        if (size != 0) {
          final double result = (size.toDouble()) / (totalPolled.toDouble());
          resultMap[i.toString()] = result;
        }
      }
    }
  }

  Future<void> onVote() async {
    if (isAnswered.isTrue) {
      return;
    }

    isAnswering.value = true;
    await IbQuestionDbService().answerQuestion(
        answer: selectedChoice.value,
        questionId: ibQuestion.id,
        uid: IbUtils.getCurrentUid()!);
    await calculateResult();
    votedDateTime.value = DateTime.now();
    isAnswering.value = false;
    isAnswered.value = true;
  }

  Future<void> onSubmit() async {
    if (isAnswered.isTrue) {
      return;
    }

    isAnswering.value = true;
    await IbQuestionDbService().answerQuestion(
        answer: selectedChoice.value,
        questionId: ibQuestion.id,
        uid: IbUtils.getCurrentUid()!);
    await calculateResult();
    votedDateTime.value = DateTime.now();
    isAnswering.value = false;
    isAnswered.value = true;
  }
}
