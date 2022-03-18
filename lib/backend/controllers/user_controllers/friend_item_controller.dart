import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class FriendItemController extends GetxController {
  IbUser user;
  final isLoading = true.obs;
  final compScore = 0.0.obs;
  final username = ''.obs;
  final avatarUrl = ''.obs;
  final isBlocked = false.obs;

  FriendItemController(this.user);

  @override
  Future<void> onInit() async {
    username.value = user.username;
    avatarUrl.value = user.avatarUrl;
    compScore.value = await IbUtils.getCompScore(uid: user.id);
    isBlocked.value =
        IbUtils.getCurrentIbUser()!.blockedFriendUids.contains(user.id);
    isLoading.value = false;
    super.onInit();
  }

  Future<void> removeFriend() async {
    final IbUser? currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null) {
      return;
    }
    try {
      await IbUserDbService().removeFriend(user.id);
      IbUtils.showSimpleSnackBar(
          msg: 'Friend deleted!', backgroundColor: IbColors.errorRed);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Delete friend failed $e', backgroundColor: IbColors.errorRed);
    }
  }

  Future<void> blockFriend() async {
    final IbUser? currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null) {
      return;
    }
    try {
      await IbUserDbService().blockFriend(user.id);
      isBlocked.value = true;
      IbUtils.showSimpleSnackBar(
          msg: 'Friend blocked!', backgroundColor: IbColors.errorRed);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Block friend failed $e', backgroundColor: IbColors.errorRed);
    }
  }

  Future<void> unblockFriend() async {
    final IbUser? currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null) {
      return;
    }
    try {
      await IbUserDbService().unblockFriend(user.id);
      isBlocked.value = false;
      IbUtils.showSimpleSnackBar(
          msg: 'Friend unblocked!', backgroundColor: IbColors.accentColor);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Unblock friend failed $e', backgroundColor: IbColors.errorRed);
    }
  }

  /// update user2 's answer list if isRefresh is true
  Future<void> refreshItem(bool isRefresh) async {
    print('refreshItem ${user.username}');
    user = (await IbUserDbService().queryIbUser(user.id))!;
    username.value = user.username;
    avatarUrl.value = user.avatarUrl;
    compScore.value =
        await IbUtils.getCompScore(uid: user.id, isRefresh: isRefresh);
    isBlocked.value =
        IbUtils.getCurrentIbUser()!.blockedFriendUids.contains(user.id);
  }
}
