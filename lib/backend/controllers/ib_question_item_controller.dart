import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../services/user_services/ib_question_db_service.dart';
import '../services/user_services/ib_tag_db_service.dart';
import '../services/user_services/ib_user_db_service.dart';

class IbQuestionItemController extends GetxController {
  final Rx<IbQuestion> rxIbQuestion;
  final showResult = false.obs;
  final isAnswering = false.obs;

  final title = ''.obs;
  final subtitle = ''.obs;
  final avatarUrl = ''.obs;
  final bool isSample;

  /// for compare two users answers
  final List<IbAnswer>? ibAnswers;
  final RxBool rxIsExpanded;

  /// show the picked option from multiple people
  final showComparison = false.obs;

  /// if user already answered, pass the answer here
  Rx<IbAnswer>? rxIbAnswer;
  final answeredUsername = ''.obs;
  final totalPolled = 0.obs;
  final likes = 0.obs;
  final liked = false.obs;
  final comments = 0.obs;
  final commented = false.obs;
  final totalTags = 0.obs;
  final selectedChoiceId = ''.obs;
  final resultMap = <IbChoice, double>{}.obs;
  final RxList<IbTag> ibTags = <IbTag>[].obs;
  Map<IbChoice, int>? countMap;

  IbQuestionItemController({
    required this.rxIbQuestion,
    required this.rxIsExpanded,
    this.isSample = false,
    this.rxIbAnswer,
    this.ibAnswers,
  });

  @override
  Future<void> onInit() async {
    /// query question author user info
    final IbUser? ibUser =
        await IbUserDbService().queryIbUser(rxIbQuestion.value.creatorId);
    if (ibUser != null) {
      /// populate title ..etc
      title.value =
          rxIbQuestion.value.isAnonymous ? 'Anonymous' : ibUser.username;
      subtitle.value = IbUtils.getAgoDateTimeString(
          DateTime.fromMillisecondsSinceEpoch(
              rxIbQuestion.value.askedTimeInMs));
      avatarUrl.value = ibUser.avatarUrl;
    }

    showComparison.value = ibAnswers != null && ibAnswers!.isNotEmpty;

    if (rxIbAnswer == null && !isSample) {
      /// query my answer to this question
      final myAnswer = await IbQuestionDbService()
          .querySingleIbAnswer(IbUtils.getCurrentUid()!, rxIbQuestion.value.id);

      if (myAnswer != null) {
        rxIbAnswer = myAnswer.obs;
        selectedChoiceId.value = rxIbAnswer!.value.choiceId;
        rxIbAnswer!.refresh();
      }
    } else if (rxIbAnswer != null) {
      selectedChoiceId.value = rxIbAnswer!.value.choiceId;
    }

    showResult.value = rxIbAnswer != null;

    if (!isSample) {
      commented.value =
          await IbQuestionDbService().isCommented(rxIbQuestion.value.id);
      comments.value = rxIbQuestion.value.comments;
      totalTags.value = rxIbQuestion.value.tagIds.length;
      liked.value = await IbQuestionDbService().isLiked(rxIbQuestion.value.id);
      likes.value = rxIbQuestion.value.likes;

      await generateIbTags();
      await generatePollStats();
    }
    super.onInit();
  }

  Future<void> generateIbTags() async {
    for (final String id in rxIbQuestion.value.tagIds) {
      final IbTag? tag = await IbTagDbService().retrieveIbTag(id);
      if (tag != null) {
        ibTags.add(tag);
      }
    }
  }

  Future<void> generatePollStats() async {
    int counter = 0;
    countMap = await IbUtils.getChoiceCountMap(rxIbQuestion.value.id);

    for (final key in countMap!.keys) {
      counter = counter + countMap![key]!;
    }

    for (final IbChoice ibChoice in rxIbQuestion.value.choices) {
      resultMap[ibChoice] = double.parse(
          ((countMap![ibChoice] ?? 0).toDouble() / counter.toDouble())
              .toStringAsFixed(1));
    }
    totalPolled.value = counter;
  }

  Future<void> onVote() async {
    if (selectedChoiceId.value.isEmpty) {
      return;
    }
    if (rxIbAnswer != null &&
        selectedChoiceId.value == rxIbAnswer!.value.choiceId) {
      return;
    }

    if (isAnswering.value) {
      return;
    }

    isAnswering.value = true;

    try {
      final IbAnswer tempAnswer = IbAnswer(
          choiceId: selectedChoiceId.value,
          answeredTimeInMs: DateTime.now().millisecondsSinceEpoch,
          askedTimeInMs: rxIbQuestion.value.askedTimeInMs,
          uid: IbUtils.getCurrentUid()!,
          questionId: rxIbQuestion.value.id,
          questionType: rxIbQuestion.value.questionType);

      await IbQuestionDbService().answerQuestion(tempAnswer);

      if (rxIbAnswer != null) {
        await IbQuestionDbService().updatePollSize(
            questionId: rxIbQuestion.value.id,
            oldChoiceId: rxIbAnswer!.value.choiceId,
            newChoiceId: selectedChoiceId.value);

        int counter = 0;
        int count1 = countMap![rxIbQuestion.value.choices.firstWhere(
                (element) => element.choiceId == rxIbAnswer!.value.choiceId)] ??
            0;
        count1 = count1 - 1 < 0 ? 0 : count1 - 1;
        countMap![rxIbQuestion.value.choices.firstWhere(
                (element) => element.choiceId == rxIbAnswer!.value.choiceId)] =
            count1;

        int count2 = countMap![rxIbQuestion.value.choices.firstWhere(
                (element) => element.choiceId == selectedChoiceId.value)] ??
            0;
        count2 = count2 + 1;
        countMap![rxIbQuestion.value.choices.firstWhere(
            (element) => element.choiceId == selectedChoiceId.value)] = count2;

        //update result map
        for (final key in countMap!.keys) {
          counter = counter + countMap![key]!;
        }

        for (final IbChoice ibChoice in rxIbQuestion.value.choices) {
          resultMap[ibChoice] = double.parse(
              ((countMap![ibChoice] ?? 0).toDouble() / counter.toDouble())
                  .toStringAsFixed(1));
        }
        totalPolled.value = counter;
      } else {
        //Todo use cloud function
        await IbQuestionDbService().increasePollSize(
            questionId: rxIbQuestion.value.id,
            choiceId: selectedChoiceId.value);

        int counter = 0;
        int count = countMap![rxIbQuestion.value.choices.firstWhere(
                (element) => element.choiceId == selectedChoiceId.value)] ??
            0;
        count = count + 1;
        countMap![rxIbQuestion.value.choices.firstWhere(
            (element) => element.choiceId == selectedChoiceId.value)] = count;

        //update result map
        for (final key in countMap!.keys) {
          counter = counter + countMap![key]!;
        }

        for (final IbChoice ibChoice in rxIbQuestion.value.choices) {
          resultMap[ibChoice] = double.parse(
              ((countMap![ibChoice] ?? 0).toDouble() / counter.toDouble())
                  .toStringAsFixed(1));
        }
        totalPolled.value = counter;
      }

      rxIbAnswer = (await IbQuestionDbService().querySingleIbAnswer(
              IbUtils.getCurrentUid()!, rxIbQuestion.value.id))!
          .obs;
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: "Failed to vote $e", backgroundColor: IbColors.errorRed);
    } finally {
      showResult.value = true;
      isAnswering.value = false;
      rxIbAnswer!.refresh();
      rxIbQuestion.refresh();
    }
  }

  Future<void> updateLike() async {
    liked.value = !liked.value;
    if (liked.isTrue) {
      likes.value++;
      //TODO use cloud function
      await IbQuestionDbService().updateLikes(rxIbQuestion.value.id);
    } else {
      await IbQuestionDbService().removeLikes(rxIbQuestion.value.id);
      likes.value--;
    }
  }
}
