import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/models/ib_user.dart';

import 'main_page_controller.dart';

class MyProfileController extends GetxController {
  final Rx<IbUser> rxIbUser = Get.find<MainPageController>().rxCurrentIbUser;
  final RxList<IbEmoPic> rxEmoPics = <IbEmoPic>[].obs;

  MyProfileController();

  @override
  void onInit() {
    super.onInit();
    rxEmoPics.value = rxIbUser.value.emoPics;
  }
}
