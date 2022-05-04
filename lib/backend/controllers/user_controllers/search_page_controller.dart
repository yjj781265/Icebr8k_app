import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_typesense_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';

import '../../models/ib_tag.dart';

class SearchPageController extends GetxController {
  final recentSearch = <String>[].obs;
  final users = <IbUser>[].obs;
  final questions = <IbQuestion>[].obs;
  final circles = <IbChat>[].obs;
  final tags = <IbTag>[].obs;
  final textEtController = TextEditingController();
  final searchText = ''.obs;
  final isSearching = false.obs;

  @override
  Future<void> onInit() async {
    textEtController.addListener(() {
      searchText.value = textEtController.text;
    });

    debounce(searchText, (value) async {
      await search();
    }, time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
    super.onInit();
  }

  Future<void> search() async {
    if (searchText.isNotEmpty) {
      isSearching.value = true;

      /// search IbUsers first
      final ids =
          await IbTypeSenseService().searchIbUsers(searchText.value.trim());
      users.clear();
      for (final id in ids) {
        if (IbCacheManager().getIbUser(id) == null) {
          final user = await IbUserDbService().queryIbUser(id);
          if (user != null) {
            users.add(user);
          }
        } else {
          final user = IbCacheManager().getIbUser(id);
          if (user != null) {
            users.add(user);
          }
        }
      }

      /// search Questions 2nd
      final questionIds =
          await IbTypeSenseService().searchIbQuestions(searchText.value.trim());
      questions.clear();
      for (final id in questionIds) {
        if (IbCacheManager().getIbQuestion(id) == null) {
          final q = await IbQuestionDbService().querySingleQuestion(id);
          if (q != null) {
            questions.add(q);
          }
        } else {
          final q = IbCacheManager().getIbQuestion(id);
          if (q != null) {
            questions.add(q);
          }
        }
      }
      questions.sort((a, b) => b.points.compareTo(a.points));

      /// search circles
      final chats =
          await IbTypeSenseService().searchIbCircles(searchText.value.trim());
      circles.clear();
      circles.value = chats;

      /// search Questions tags
      final results =
          await IbTypeSenseService().searchIbTags(searchText.value.trim());
      tags.clear();
      tags.value = results;
      isSearching.value = false;
    } else {
      tags.clear();
      users.clear();
      circles.clear();
      questions.clear();
      isSearching.value = false;
    }
  }
}
