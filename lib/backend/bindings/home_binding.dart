import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/chat_tab_controller.dart';
import 'package:icebr8k/backend/controllers/friend_list_controller.dart';
import 'package:icebr8k/backend/controllers/friend_request_controller.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/backend/controllers/ib_question_controller.dart';
import 'package:icebr8k/backend/controllers/my_answered_quetions_controller.dart';
import 'package:icebr8k/backend/controllers/people_nearby_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(IbQuestionController());
    Get.put(ChatTabController());
    Get.put(FriendListController());
    Get.put(FriendRequestController());
    Get.put(MyAnsweredQuestionsController());
    Get.put(PeopleNearbyController());
  }
}
