import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';

import '../../managers/Ib_analytics_manager.dart';
import '../../models/ib_question.dart';

class WordCloudController extends GetxController {
  final isLoading = true.obs;
  final IbUser user;
  final userIbTagMap = <String, int>{};

  WordCloudController(this.user);

  @override
  Future<void> onReady() async {
    List<IbAnswer> ibAnswers = [];
    if (IbCacheManager().getIbAnswers(user.id) == null) {
      ibAnswers = await IbQuestionDbService().queryUserAnswers(user.id);
      IbCacheManager().cacheIbAnswers(uid: user.id, ibAnswers: ibAnswers);
    } else {
      ibAnswers = IbCacheManager().getIbAnswers(user.id) ?? [];
    }

    if (ibAnswers.isNotEmpty) {
      for (final answer in ibAnswers) {
        late IbQuestion? question;
        if (IbCacheManager().getIbQuestion(answer.questionId) == null) {
          question = await IbQuestionDbService()
              .querySingleQuestion(answer.questionId);
          if (question == null) {
            continue;
          }
          IbCacheManager().cacheSingleIbQuestion(question);
        } else {
          question = IbCacheManager().getIbQuestion(answer.questionId);
        }

        /// populate map
        for (final String text in question!.tags) {
          int counter = userIbTagMap[text] ?? 0;
          counter++;
          userIbTagMap[text] = counter;
        }
      }
      isLoading.value = false;
    } else {
      isLoading.value = false;
    }

    await IbAnalyticsManager().logScreenView(
        className: 'WordCloudController', screenName: 'WordCloudPage');
    _showIntroDialog();
    super.onReady();
  }

  void _showIntroDialog() {
    if (IbLocalDataService().retrieveBoolValue(StorageKey.wordCloudIntro)) {
      return;
    }
    Get.dialog(const IbDialog(
      title: 'Welcome to word cloud ☁',
      subtitle:
          'Word cloud shows user past top voted 16 tags based on voting history',
      showNegativeBtn: false,
    ));
    IbLocalDataService()
        .updateBoolValue(key: StorageKey.wordCloudIntro, value: true);
  }
}
