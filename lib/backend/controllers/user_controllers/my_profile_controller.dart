import 'package:get/get.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../models/ib_chat_models/ib_chat.dart';

class MyProfileController extends GetxController {
  final circles = <IbChat>[].obs;

  MyProfileController();

  @override
  Future<void> onInit() async {
    super.onInit();
    circles.value =
        await IbChatDbService().queryUserCircles(IbUtils.getCurrentUid()!);
  }
}
