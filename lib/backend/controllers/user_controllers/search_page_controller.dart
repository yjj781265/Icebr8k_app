import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/managers/ib_ad_manager.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_typesense_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/backend/services/user_services/icebreaker_db_service.dart';
import 'package:icebr8k/frontend/ib_config.dart';

import '../../models/ib_tag.dart';

class SearchPageController extends GetxController {
  final recentSearch = <String>[].obs;
  final allIcebreakers = <Icebreaker>[];
  final icebreakers = <Icebreaker>[].obs;
  final users = <IbUser>[].obs;
  final questions = <IbQuestion>[].obs;
  final circles = <IbChat>[].obs;
  final tags = <IbTag>[].obs;
  final textEtController = TextEditingController();
  final searchText = ''.obs;
  final isSearching = false.obs;
  final isLoadingAd = true.obs;
  BannerAd ad = IbAdManager().getBanner2();

  @override
  Future<void> onInit() async {
    await ad.load();
    isLoadingAd.value = false;
    textEtController.addListener(() {
      if (searchText.value == textEtController.text) {
        return;
      }
      searchText.value = textEtController.text;
      isSearching.value = searchText.trim().isNotEmpty;
    });

    final ibCollections = await IcebreakerDbService().queryIbCollections();

    for (final collection in ibCollections) {
      allIcebreakers.addAll(collection.icebreakers);
    }

    debounce(searchText, (value) async {
      await search();
    }, time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
    super.onInit();
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    ad.dispose();
    textEtController.dispose();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'SearchPageController', screenName: 'SearchPage');
  }

  Future<void> search() async {
    if (searchText.trim().isNotEmpty) {
      await IbAnalyticsManager().logSearch(searchText.trim());

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

      final results =
          await IbTypeSenseService().searchIbTags(searchText.value.trim());
      tags.clear();
      tags.value = results;

      /// search all icebreakers
      icebreakers.clear();
      for (final item in allIcebreakers) {
        final list = item.text.split(' ');
        for (final String str in list) {
          if (str.toLowerCase().startsWith(searchText.value.toLowerCase()) ||
              searchText.value
                  .toLowerCase()
                  .split(' ')
                  .contains(str.toLowerCase())) {
            icebreakers.addIf(!icebreakers.contains(item), item);
          }
        }
      }

      isSearching.value = false;
    } else {
      tags.clear();
      users.clear();
      circles.clear();
      questions.clear();
      icebreakers.clear();
      isSearching.value = false;
    }
  }
}
