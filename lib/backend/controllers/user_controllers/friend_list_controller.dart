import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class FriendListController extends GetxController {
  final IbUser user;
  final items = <FriendItem>[].obs;
  final isLoading = true.obs;

  FriendListController(this.user);

  @override
  Future<void> onInit() async {
    super.onInit();
    final ibUser = await IbUserDbService().queryIbUser(user.id);

    if (ibUser == null) {
      return;
    }

    for (final String id in ibUser.friendUids) {
      IbUser? user = IbCacheManager().getIbUser(id);
      if (user != null) {
        final compScore = await IbUtils.getCompScore(uid: user.id);
        items.add(FriendItem(user: user, compScore: compScore));
      } else {
        user = await IbUserDbService().queryIbUser(id);
        if (user != null) {
          final compScore = await IbUtils.getCompScore(uid: user.id);
          items.add(FriendItem(user: user, compScore: compScore));
        }
      }
    }

    items.sort((a, b) => b.compScore.compareTo(a.compScore));

    isLoading.value = false;
  }
}
