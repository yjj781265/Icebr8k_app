import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/admin_main_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/notifications_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';

import '../controllers/user_controllers/home_tab_controller.dart';
import '../controllers/user_controllers/people_nearby_controller.dart';

class HomeBinding implements Bindings {
  IbUser currentIbUser;

  HomeBinding(this.currentIbUser);

  @override
  void dependencies() {
    Get.lazyPut(
        () => MainPageController(
            rxCurrentIbUser: currentIbUser.obs,
            userDbService: IbUserDbService()),
        fenix: true);
    Get.lazyPut(() => HomeTabController(), fenix: true);
    Get.lazyPut(() => SocialTabController(), fenix: true);
    Get.lazyPut(() => NotificationController(), fenix: true);
    Get.lazyPut(() => PeopleNearbyController(), fenix: true);
    Get.put(AdminMainController());
  }
}
