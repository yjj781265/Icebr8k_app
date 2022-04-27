import 'dart:async';

import 'package:get/get.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/backend/services/user_services/icebreaker_db_service.dart';

class IcebreakerController extends GetxController {
  IbCollection ibCollection;
  final icebreakers = <Icebreaker>[].obs;
  final bool isEdit;
  late StreamSubscription icebreakerSub;

  IcebreakerController(this.ibCollection, {this.isEdit = false});

  @override
  Future<void> onInit() async {
    icebreakerSub = IcebreakerDbService()
        .listenToIcebreakerChange(ibCollection)
        .listen((event) {
      if (event.data() == null) {
        return;
      }

      ibCollection = IbCollection.fromJson(event.data()!);
      icebreakers.value = ibCollection.icebreakers;
    });
    super.onInit();
  }

  @override
  Future<void> onClose() async {
    await icebreakerSub.cancel();
    super.onClose();
  }
}
