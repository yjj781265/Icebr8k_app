import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/ib_cache_manager.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';

class IbFriendsPickerController extends GetxController {
  final items = <IbUser, bool>{}.obs;
  final isSearching = false.obs;
  final TextEditingController txtEditController = TextEditingController();
  final String uid;
  final searchItems = <IbUser, bool>{}.obs;
  final List<String> pickedUids;

  IbFriendsPickerController(this.uid, {this.pickedUids = const []});

  @override
  Future<void> onInit() async {
    final ibUser = await IbUserDbService().queryIbUser(uid);
    if (ibUser != null) {
      for (final i in ibUser.friendUids) {
        late IbUser? user;
        if (IbCacheManager().getIbUser(i) == null) {
          user = await IbUserDbService().queryIbUser(i);
        } else {
          user = IbCacheManager().getIbUser(i);
        }

        if (user != null) {
          items[user] = pickedUids.contains(user.id);
        }
      }
    }

    txtEditController.addListener(() {
      searchItems.clear();
      searchItems.addAll(items);
      if (txtEditController.text.isEmpty) {
        isSearching.value = false;
      } else {
        searchItems.removeWhere((key, value) =>
            !key.username.contains(txtEditController.text.trim()));
        isSearching.value = true;
      }
      searchItems.refresh();
    });

    super.onInit();
  }

  /*Future<void> sendInvites() async {
    final List<IbUser> users = items.keys
        .where((element) =>
            !pickedUids.contains(element.id) && items[element] == true)
        .toList();

    for (final IbUser user in users) {
      final IbNotification notification = IbNotification(
          id: ibChat.chatId,
          title: '',
          subtitle: '',
          type: IbNotification.kGroupInvite,
          timestampInMs: DateTime.now().millisecondsSinceEpoch,
          senderId: ibChat.photoUrl,
          recipientId: user.id);
      await IbUserDbService().sendAlertNotification(notification);
    }
  }*/
}
