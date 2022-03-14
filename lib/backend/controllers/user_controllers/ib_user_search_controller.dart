import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../services/user_services/ib_user_db_service.dart';
import 'auth_controller.dart';

class IbUserSearchController extends GetxController {
  final searchTxt = ''.obs;
  final friendUid = ''.obs;
  final username = ''.obs;
  final avatarUrl = ''.obs;
  final friendshipStatus = ''.obs;
  final score = (-1.0).obs;
  final isSearching = false.obs;
  final noResultTrKey = ''.obs;
  IbUser? ibUser;
  String requestMsg = '';

  @override
  void onInit() {
    super.onInit();
    debounce(searchTxt, (_) => _searchIbUsername(),
        time:
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
  }

  void _searchIbUsername() {
    _reset();
    isSearching.value = true;
    IbUserDbService()
        .queryIbUserFromUsername(searchTxt.value)
        .then((user) async {
      if (user == null) {
        _reset();
        noResultTrKey.value = 'user_not_found';
        return;
      }
      ibUser = user;
      noResultTrKey.value = '';
      username.value = user.username;
      avatarUrl.value = user.avatarUrl;
      friendUid.value = user.id;
      final String? status = await IbUserDbService().queryFriendshipStatus(
          Get.find<AuthController>().firebaseUser!.uid, user.id);
      friendshipStatus.value = status ?? '';
      score.value = await IbUtils.getCompScore(uid: friendUid.value);
      isSearching.value = false;
    });
  }

  void _reset() {
    username.value = '';
    avatarUrl.value = '';
    score.value = -1.0;
    friendUid.value = '';
    isSearching.value = false;
    noResultTrKey.value = '';
    friendshipStatus.value = '';
    requestMsg = '';
  }
}
