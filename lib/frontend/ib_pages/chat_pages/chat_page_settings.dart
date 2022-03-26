import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_friends_picker_controller.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/ib_friends_picker.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:reorderables/reorderables.dart';

class ChatPageSettings extends StatelessWidget {
  const ChatPageSettings(this._controller, {Key? key}) : super(key: key);
  final ChatPageController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(_controller.title.value),
        ),
      ),
      body: getBody(context),
    );
  }

  Widget getBody(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          if (_controller.isCircle.isTrue) membersList(context),
          settings(context),
        ],
      ),
    );
  }

  Widget membersList(BuildContext context) {
    return Obx(() => Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Members(${_controller.ibChatMembers.length})',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: IbConfig.kNormalTextSize),
              ),
              const SizedBox(
                height: 8,
              ),
              ReorderableWrap(
                runSpacing: 8,
                spacing: 8,
                onReorder: (int oldIndex, int newIndex) {},
                footer: CircleAvatar(
                  radius: 24,
                  backgroundColor: IbColors.lightGrey,
                  child: IconButton(
                    onPressed: () async {
                      final items = await Get.to(
                        () => IbFriendsPicker(
                          Get.put(
                            IbFriendsPickerController(
                              IbUtils.getCurrentUid()!,
                              pickedUids: _controller.ibChatMembers
                                  .map((element) => element.user.id)
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                  ),
                ),
                children: _controller.ibChatMembers.map((element) {
                  return SizedBox(
                    width: 72,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IbUserAvatar(avatarUrl: element.user.avatarUrl),
                        Text(
                          element.user.username,
                          style: const TextStyle(
                              fontSize: IbConfig.kNormalTextSize),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          element.member.role,
                          style: TextStyle(
                              color: element.member.role ==
                                      IbChatMember.kRoleLeader
                                  ? Theme.of(context).indicatorColor
                                  : IbColors.lightGrey,
                              fontSize: IbConfig.kDescriptionTextSize),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const Divider(
                thickness: 2,
              ),
            ],
          ),
        ));
  }

  Widget settings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Settings',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: IbConfig.kNormalTextSize),
          ),
        ),
        Obx(
          () => SwitchListTile.adaptive(
            value: _controller.isMuted.value,
            onChanged: (value) async {
              if (value) {
                await _controller.muteNotification();
              } else {
                await _controller.unMuteNotification();
              }
            },
            title: const Text('Mute Notifications'),
          ),
        ),
        ListTile(
          onTap: () {},
          leading: const Icon(
            FontAwesomeIcons.signOutAlt,
            color: IbColors.errorRed,
          ),
          title: const Text(
            'Leave Chat',
            style: TextStyle(color: IbColors.errorRed),
          ),
        ),
      ],
    );
  }
}
