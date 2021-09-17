import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/ib_user_search_controller.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_linear_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_config.dart';

class IbUserSearchPage extends StatelessWidget {
  IbUserSearchPage({Key? key}) : super(key: key);
  final IbUserSearchController _controller = Get.put(IbUserSearchController());
  final _txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      appBar: AppBar(
        backgroundColor: IbColors.lightBlue,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextField(
                  autofocus: true,
                  controller: _txtController,
                  onChanged: (text) {
                    _controller.isSearching.value = true;
                    _controller.searchTxt.value = text;
                  },
                  decoration: InputDecoration(
                    hintText: 'username_search_hint'.tr,
                  ),
                ),
              ),
            ),
            Obx(() {
              if (_controller.searchTxt.isNotEmpty) {
                return IconButton(
                  onPressed: () {
                    _txtController.clear();
                    _controller.username.value = '';
                  },
                  icon: const Icon(Icons.cancel_outlined),
                );
              }
              return const SizedBox(
                width: 48,
              );
            }),
          ],
        ),
      ),
      body: _getBody(),
    );
  }

  Widget _getBody() {
    return Obx(() {
      if (_controller.searchTxt.value.isEmpty) {
        return const SizedBox();
      }

      if (_controller.isSearching.isTrue) {
        return const Center(
          child: IbProgressIndicator(),
        );
      }

      if (_controller.isSearching.isFalse &&
          _controller.noResultTrKey.value.isNotEmpty) {
        return Center(
          child: Text(_controller.noResultTrKey.value.tr),
        );
      }

      if (_controller.isSearching.isFalse &&
          _controller.username.isNotEmpty &&
          _controller.noResultTrKey.value.isEmpty) {
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              onTap: () => Get.to(
                  () => ProfilePage(
                        _controller.ibUser!.id,
                        showAppBar: true,
                      ),
                  preventDuplicates: false),
              tileColor: IbColors.white,
              leading: IbUserAvatar(
                avatarUrl: _controller.ibUser!.avatarUrl,
                uid: _controller.ibUser!.id,
              ),
              title: Text(
                _controller.username.value,
                style: const TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    fontWeight: FontWeight.bold),
              ),
              subtitle: IbLinearIndicator(endValue: _controller.score.value),
              trailing: handleFriendshipStatus(),
            ));
      }

      return const SizedBox();
    });
  }

  void showFriendRequestDialog() {
    final Widget dialog = IbCard(
        child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'friend_request_dialog_title'
                .trParams({'username': _controller.username.value}),
            style: const TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IbUserAvatar(
                  avatarUrl: _controller.ibUser!.avatarUrl,
                  uid: _controller.ibUser!.id,
                  radius: 32,
                ),
              ),
              Expanded(
                child: TextField(
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  onChanged: (requestMsg) {
                    _controller.requestMsg = requestMsg;
                  },
                  autofocus: true,
                  style: const TextStyle(
                    fontSize: IbConfig.kSecondaryTextSize,
                  ),
                  maxLength: IbConfig.kFriendRequestMsgMaxLength,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintStyle: const TextStyle(color: IbColors.lightGrey),
                    hintText: 'friend_request_msg_hint'.tr,
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                  child: IbElevatedButton(
                onPressed: () {
                  Get.back();
                },
                textTrKey: 'cancel',
                color: IbColors.primaryColor,
              )),
              Expanded(
                flex: 2,
                child: IbElevatedButton(
                  onPressed: () {
                    _controller.sendFriendRequest();
                    Get.back();
                    IbUtils.hideKeyboard();
                  },
                  textTrKey: 'send_friend_request',
                ),
              ),
            ],
          )
        ],
      ),
    ));

    Get.bottomSheet(dialog);
  }

  Widget handleFriendshipStatus() {
    return Obx(() {
      final bool isMe = Get.find<AuthController>().firebaseUser!.uid ==
          _controller.friendUid.value;

      if (isMe) {
        return const SizedBox();
      }

      if (_controller.friendshipStatus.isEmpty) {
        return IconButton(
          tooltip: _controller.friendshipStatus.value,
          onPressed: () {
            showFriendRequestDialog();
          },
          icon: const Icon(Icons.person_add_alt_1_outlined),
        );
      }

      if (_controller.friendshipStatus.value ==
          IbFriend.kFriendshipStatusPending) {
        return IconButton(
          onPressed: null,
          tooltip: _controller.friendshipStatus.value,
          icon: const Icon(Icons.pending_outlined),
        );
      }

      if (_controller.friendshipStatus.value ==
          IbFriend.kFriendshipStatusRequestSent) {
        return IconButton(
          onPressed: null,
          tooltip: _controller.friendshipStatus.value,
          icon: const Icon(Icons.pending_outlined),
        );
      }

      return const SizedBox();
    });
  }
}
