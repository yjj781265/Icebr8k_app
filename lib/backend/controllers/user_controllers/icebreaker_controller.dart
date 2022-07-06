import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/backend/services/user_services/icebreaker_db_service.dart';

class IcebreakerController extends GetxController {
  IbCollection ibCollection;
  final icebreakers = <Icebreaker>[].obs;
  final currentIndex = 0.obs;
  final bool isEdit;
  final isLoading = true.obs;
  final isShuffling = false.obs;
  final hasEditAccess = false.obs;
  final isEditing = false.obs;
  final ScrollController scrollController = ScrollController();

  late StreamSubscription icebreakerSub;
  CarouselController carouselController = CarouselController();

  IcebreakerController(this.ibCollection, {required this.isEdit});

  @override
  Future<void> onReady() async {
    await IbAnalyticsManager().logScreenView(
        className: 'IcebreakerController', screenName: 'IcebreakerMainPage');
    super.onReady();
  }

  @override
  Future<void> onInit() async {
    icebreakerSub = IcebreakerDbService()
        .listenToIcebreakerChange(ibCollection)
        .listen((event) {
      if (event.data() == null) {
        isLoading.value = false;
        return;
      }

      ibCollection = IbCollection.fromJson(event.data()!);
      icebreakers.value = ibCollection.icebreakers;
      isLoading.value = false;
    });

    hasEditAccess.value = isEdit;
    isEditing.value = isEdit;
    super.onInit();
  }

  Future<void> shuffleCards() async {
    if (isShuffling.isTrue || isEditing.isTrue) {
      return;
    }
    currentIndex.value = 0;
    isShuffling.value = true;
    await HapticFeedback.vibrate();
    await Future.delayed(const Duration(milliseconds: 2200));
    icebreakers.shuffle();
    isShuffling.value = false;
    await HapticFeedback.selectionClick();
  }

  @override
  Future<void> onClose() async {
    await icebreakerSub.cancel();
    super.onClose();
  }
}
