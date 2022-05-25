import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_tag_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../models/ib_question.dart';

class TagPageController extends GetxController {
  final String text;
  IbUser? user;
  final ibTag = IbTag(text: '', creatorId: '').obs;
  final creatorUsername = ''.obs;
  final total = 0.obs;
  final ibQuestions = <IbQuestion>[].obs;
  final isFollower = false.obs;
  final url = ''.obs;
  final isLoading = true.obs;
  DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  RefreshController refreshController = RefreshController();
  TagPageController(this.text);

  @override
  Future<void> onInit() async {
    final tag = await IbTagDbService().retrieveIbTag(text);
    if (tag != null) {
      ibTag.value = tag;
      total.value = ibTag.value.questionCount;
      isFollower.value = IbUtils.getCurrentIbUser()!.tags.contains(text);

      user = await IbUserDbService().queryIbUser(ibTag.value.creatorId);
      if (user != null) {
        creatorUsername.value = user!.username;
      }

      ibTag.refresh();
      final snapshot =
          await IbQuestionDbService().queryTagIbQuestions(text: text);

      for (final doc in snapshot.docs) {
        ibQuestions.add(IbQuestion.fromJson(doc.data()));
        lastDoc = doc;
      }
      final mediaQ =
          ibQuestions.firstWhereOrNull((element) => element.medias.isNotEmpty);
      if (mediaQ != null) {
        url.value = mediaQ.medias.first.url;
      }
    }
    isLoading.value = false;
    super.onInit();
  }

  Future<void> loadMore() async {
    if (lastDoc == null) {
      refreshController.loadNoData();
      return;
    }

    final snapshot = await IbQuestionDbService()
        .queryTagIbQuestions(text: text, lastDoc: lastDoc);

    for (final doc in snapshot.docs) {
      ibQuestions.add(IbQuestion.fromJson(doc.data()));
      lastDoc = doc;
    }

    if (snapshot.docs.isEmpty) {
      lastDoc = null;
      refreshController.loadNoData();
    }
  }

  Future<void> updateFollowTag() async {
    if (isFollower.isFalse) {
      await IbUserDbService().followTag(tag: text);
      isFollower.value = true;
    } else {
      await IbUserDbService().unfollowTag(tag: text);
      isFollower.value = false;
    }
  }
}
