import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_settings_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_friends_picker_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_chat_member.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/circle_settings.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/my_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import 'ib_friends_picker.dart';

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
    return SafeArea(
      child: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_controller.isCircle.isTrue) membersList(context),
              settings(context),
            ],
          ),
        ),
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
              Wrap(runSpacing: 8, spacing: 8, children: [
                Wrap(
                  runSpacing: 8,
                  spacing: 8,
                  children: _controller.ibChatMembers.map((element) {
                    return InkWell(
                      onTap: () {
                        _showMemberBtmSheet(element);
                      },
                      child: SizedBox(
                        width: 72,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IbUserAvatar(
                              avatarUrl: element.user.avatarUrl,
                              compScore: element.compScore,
                            ),
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
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(
                  width: 72,
                  child: IbActionButton(
                    iconData: Icons.add,
                    text: '',
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
                      if (items == null) {
                        return;
                      }
                      final List<IbUser> invitees = [];
                      for (final dynamic item in items) {
                        invitees.add(item as IbUser);
                      }
                      await _controller.sendCircleInvites(invitees);
                    },
                    color: IbColors.lightGrey,
                  ),
                ),
              ]),
              const Divider(
                thickness: 2,
              ),
            ],
          ),
        ));
  }

  void _showMemberBtmSheet(IbChatMemberModel model) {
    final item = _controller.ibChatMembers.firstWhereOrNull(
        (element) => element.user.id == IbUtils.getCurrentUid()!);
    if (item == null) {
      return;
    }

    final bool isLeader = item.member.role == IbChatMember.kRoleLeader;
    final bool isAssistant = item.member.role == IbChatMember.kRoleAssistant;

    final Widget sheet = IbCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              Get.back();
              if (model.user.id == IbUtils.getCurrentUid()) {
                Get.to(() => MyProfilePage());
                return;
              }
              Get.to(
                  () => ProfilePage(Get.put(ProfileController(model.user.id))));
            },
            title: const Text('View Profile'),
          ),
          if (isLeader && model != item)
            ListTile(
              onTap: () async {
                Get.back();
                await _controller.transferLeadership(model);
              },
              title: const Text('Transfer Leadership'),
            ),
          if ((isAssistant || isLeader) &&
              model.member.role == IbChatMember.kRoleMember)
            ListTile(
              onTap: () async {
                Get.back();
                await _controller.promoteToAssistant(model);
              },
              title: const Text('Promote to Assistant'),
            ),
          if (isLeader && model.member.role == IbChatMember.kRoleAssistant)
            ListTile(
              onTap: () async {
                Get.back();
                await _controller.demoteToMember(model);
              },
              title: const Text('Demote to Member'),
            ),
          if (isLeader)
            ListTile(
              onTap: () async {
                Get.back();
                _controller.removeFromCircle(model);
              },
              title: const Text(
                'Remove from Circle',
                style: TextStyle(color: IbColors.errorRed),
              ),
            ),
        ],
      ),
    );

    Get.bottomSheet(sheet, ignoreSafeArea: false);
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
        Obx(() {
          final chatMember = _controller.ibChatMembers.firstWhereOrNull(
              (element) => element.member.uid == IbUtils.getCurrentUid()!);
          if (chatMember != null &&
              _controller.isCircle.isTrue &&
              (chatMember.member.role == IbChatMember.kRoleLeader ||
                  chatMember.member.role == IbChatMember.kRoleAssistant)) {
            return ListTile(
              onTap: () {
                Get.to(
                  () => CircleSettings(
                    Get.put(
                      CircleSettingsController(
                        ibChat: _controller.ibChat,
                      ),
                    ),
                  ),
                );
              },
              title: const Text('Edit Circle Info'),
              trailing: const Icon(Icons.edit),
            );
          }
          if (chatMember != null &&
              _controller.isCircle.isTrue &&
              (chatMember.member.role == IbChatMember.kRoleMember)) {
            return ListTile(
              onTap: () {
                Get.to(() => CircleSettings(Get.put(CircleSettingsController(
                    ibChat: _controller.ibChat, isAbleToEdit: false))));
              },
              title: const Text('Circle Info'),
              trailing: const Icon(Icons.info),
            );
          }
          return const SizedBox();
        }),
        const ListTile(
          leading: Icon(
            FontAwesomeIcons.rightFromBracket,
            color: IbColors.errorRed,
          ),
          title: Text(
            'Leave Chat',
            style: TextStyle(color: IbColors.errorRed),
          ),
        ),
      ],
    );
  }
}
