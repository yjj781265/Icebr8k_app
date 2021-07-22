import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';

class IbQuestionController extends GetxController {
  List<IbQuestion> ibQuestions = [];
  final isLoading = true.obs;
  final id = 'tCH8AIqRxWM0eEQcmlnniUIfo6F3';

  @override
  Future<void> onInit() async {
    ibQuestions =
        await IbQuestionDbService().queryQuestions(creatorId: id, limit: 10);
    isLoading.value = false;
    super.onInit();
  }
}
