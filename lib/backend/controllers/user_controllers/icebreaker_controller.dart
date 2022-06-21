import 'dart:async';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/backend/services/user_services/icebreaker_db_service.dart';
import 'package:shake/shake.dart';

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
  late ShakeDetector detector;
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
    detector = ShakeDetector.waitForStart(
        onPhoneShake: () async {
          await shuffleCards();
        },
        shakeThresholdGravity: 2.5,
        minimumShakeCount: 2);
    detector.startListening();

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

/*  void showShakePopup() {
    if (isEdit) {
      return;
    }
    Get.dialog(Padding(
      padding: const EdgeInsets.all(8.0),
      child: IbDialog(
        title: 'Shake your phone to shuffle questions',
        subtitle: '',
        content: Center(
          child: SizedBox(
              height: 200,
              width: 200,
              child: Lottie.asset('assets/images/shake.json')),
        ),
        showNegativeBtn: false,
      ),
    ));
  }*/

  @override
  Future<void> onClose() async {
    await icebreakerSub.cancel();
    detector.stopListening();
    super.onClose();
  }
}
