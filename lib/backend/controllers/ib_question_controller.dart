import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbQuestionController extends GetxController {
  List<IbQuestion> ibQuestions = [];

  @override
  void onInit() {
    IbQuestion ibQuestion = IbQuestion(
        question: 'Coke or Pepsi',
        id: IbUtils.getUniqueName(),
        creatorId: 'NvpFOtXWoiVdctRgVHRy2EFxs0O2',
        choices: ['Coke', 'Pepsi'],
        questionType: IbQuestion.kScale,
        description: 'Which one tastes better?',
        createdTimeInMs: 1626451911000);

    IbQuestion ibQuestion2 = IbQuestion(
        question: 'Best sports',
        id: IbUtils.getUniqueName(),
        creatorId: 'NvpFOtXWoiVdctRgVHRy2EFxs0O2',
        choices: ['Basketball', 'Baseball', 'Football', 'Hockey', 'Volleyball'],
        questionType: IbQuestion.kMultipleChoice,
        description: 'Which one tastes better?',
        createdTimeInMs: DateTime.now().millisecondsSinceEpoch);

    IbQuestion ibQuestion3 = IbQuestion(
        question: 'Best game',
        id: IbUtils.getUniqueName(),
        creatorId: 'NvpFOtXWoiVdctRgVHRy2EFxs0O2',
        choices: ['Overwatch', 'League of Legend', 'PUBG', 'Apx Legend'],
        questionType: IbQuestion.kMultipleChoice,
        description: 'Which one tastes better?',
        createdTimeInMs: DateTime.now().millisecondsSinceEpoch);

    ibQuestions.add(ibQuestion);
    ibQuestions.add(ibQuestion2);
    ibQuestions.add(ibQuestion3);
    for (int i = 0; i < 50; i++) {
      ibQuestions.add(IbQuestion(
          question: 'Pancake or Waffle',
          id: IbUtils.getUniqueName(),
          creatorId: 'NvpFOtXWoiVdctRgVHRy2EFxs0O2',
          choices: ['Pancake', 'Waffle'],
          questionType: IbQuestion.kMultipleChoice,
          description: 'Which one tastes better?',
          createdTimeInMs: DateTime.now().millisecondsSinceEpoch));
    }
    super.onInit();
  }
}
