import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/ib_user_search_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_strings.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
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
            tileColor: IbColors.white,
            subtitle: TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: _controller.score.value),
                duration: Duration(
                    milliseconds: _controller.score.value < 0.5
                        ? IbConfig.kEventTriggerDelayInMillis
                        : 1200),
                builder: (context, double value, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          color: _handleIndicatorColor(value),
                          backgroundColor: IbColors.lightGrey,
                          minHeight: 5,
                          value: value,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text('${(value * 100).toInt()}%'),
                      )
                    ],
                  );
                }),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(IbConfig.kCardCornerRadius),
            ),
            leading: IbUserAvatar(
              avatarUrl: _controller.avatarUrl.value,
            ),
            title: Text(
              _controller.username.value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            trailing: handleFriendshipStatus(),
          ),
        );
      }

      return const SizedBox();
    });
  }

  Color _handleIndicatorColor(double value) {
    if (value > 0 && value <= 0.2) {
      return const Color(0xFFFF0000);
    }

    if (value > 0.2 && value <= 0.4) {
      return const Color(0xFFFF6600);
    }

    if (value > 0.4 && value <= 0.6) {
      return const Color(0xFFFFB700);
    }

    if (value > 0.6 && value <= 0.8) {
      return const Color(0xFFB3FF00);
    }

    if (value > 0.8 && value <= 1.0) {
      return IbColors.accentColor;
    }
    return IbColors.errorRed;
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
                    .trParams({'username': _controller.username.value}) ??
                '',
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
                  avatarUrl: _controller.avatarUrl.value,
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
          onPressed: () {
            showFriendRequestDialog();
          },
          icon: const Icon(Icons.person_add_alt_1_outlined),
        );
      }

      if (_controller.friendshipStatus.value ==
          IbStrings.kFriendshipStatusPending) {
        return IconButton(
          onPressed: null,
          tooltip: 'friend_request_pending_tip'.tr,
          icon: const Icon(Icons.pending_outlined),
        );
      }

      if (_controller.friendshipStatus.value ==
          IbStrings.kFriendshipStatusRequestSent) {
        return IconButton(
          onPressed: null,
          tooltip: 'friend_request_pending_tip'.tr,
          icon: const Icon(Icons.pending_outlined),
        );
      }

      return const SizedBox();
    });
  }
}
