import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';

class FriendListController extends GetxController {
  final IbUser user;
  final users = <IbUser>[].obs;
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
      if (IbCacheManager().getIbUser(id) != null) {
        users.add(IbCacheManager().getIbUser(id)!);
      } else {
        final user = await IbUserDbService().queryIbUser(id);
        if (user != null) {
          users.add(user);
        }
      }
    }

    isLoading.value = false;
  }
}
