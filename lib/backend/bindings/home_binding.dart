import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/chat_tab_controller.dart';
import 'package:icebr8k/backend/controllers/friend_list_controller.dart';
import 'package:icebr8k/backend/controllers/friend_request_controller.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/controllers/people_nearby_controller.dart';
import 'package:icebr8k/backend/controllers/social_tab_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SocialTabController(), fenix: true);
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.lazyPut(() => IbQuestionController(), fenix: true);
    Get.lazyPut(() => ChatTabController(), fenix: true);
    Get.lazyPut(() => FriendListController(), fenix: true);
    Get.lazyPut(() => FriendRequestController(), fenix: true);
    Get.lazyPut(() => PeopleNearbyController(), fenix: true);
  }
}
