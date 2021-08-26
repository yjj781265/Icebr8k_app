import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class ProfileController extends GetxController {
  final currentIndex = 0.obs;
  final String uid;
  final avatarUrl = ''.obs;
  final coverPhotoUrl = ''.obs;
  final username = ''.obs;
  final name = ''.obs;
  final description = ''.obs;
  final isMe = false.obs;
  final compScore = 0.0.obs;
  final totalAsked = 0.obs;
  final totalAnswered = 0.obs;
  StreamSubscription? totalAskedStream;
  StreamSubscription? totalAnsweredStream;
  ProfileController(this.uid);

  @override
  Future<void> onInit() async {
    isMe.value = uid == IbUtils.getCurrentUid();
    if (isMe.isFalse) {
      compScore.value =
          await IbUtils.getCompScore(IbUtils.getCurrentUid()!, uid);

      // TODO convert to cloud function for getting the total count, important!
      final List ids =
          await IbQuestionDbService().queryAnsweredQuestionIds(uid);
      totalAnswered.value = ids.length;

      final snapshot = await IbQuestionDbService().queryUserQuestions(uid: uid);
      totalAsked.value = snapshot.size;
    } else {
      totalAskedStream = IbQuestionDbService()
          .listenToAnsweredQuestionsChange(uid)
          .listen((event) async {
        // TODO convert to cloud function for getting the total count, important!
        final List ids =
            await IbQuestionDbService().queryAnsweredQuestionIds(uid);
        totalAnswered.value = ids.length;
      });

      totalAnsweredStream = IbQuestionDbService()
          .listenToUserCreatedQuestionsChange(uid)
          .listen((event) async {
        final snapshot =
            await IbQuestionDbService().queryUserQuestions(uid: uid);
        totalAsked.value = snapshot.size;
      });
    }

    final IbUser? user = await IbUserDbService().queryIbUser(uid);
    if (user == null) {
      return;
    }

    avatarUrl.value = user.avatarUrl;
    coverPhotoUrl.value = user.coverPhotoUrl;
    username.value = user.username;
    name.value = user.name;
    description.value = user.description;
    super.onInit();
  }

  @override
  void onClose() {
    if (totalAskedStream != null) {
      totalAskedStream!.cancel();
    }

    if (totalAnsweredStream != null) {
      totalAnsweredStream!.cancel();
    }

    super.onClose();
  }
}
