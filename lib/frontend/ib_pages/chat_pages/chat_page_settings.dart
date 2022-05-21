import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
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
import 'package:icebr8k/frontend/ib_pages/chat_pages/friends_picker.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/past_icebreakers.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/past_polls.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/my_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../../ib_widgets/ib_dialog.dart';

class ChatPageSettings extends StatelessWidget {
  const ChatPageSettings(this._controller, {Key? key}) : super(key: key);
  final ChatPageController _controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Obx(
            () => Text(_controller.title.value),
          ),
          actions: [
            if (_controller.isCircle.isTrue)
              IconButton(
                  onPressed: () async {
                    if (_controller.ibChatMembers.length >=
                        IbConfig.kCircleMaxMembers) {
                      IbUtils.showSimpleSnackBar(
                          msg:
                              'Circle reached ${IbConfig.kCircleMaxMembers} members limit',
                          backgroundColor: IbColors.primaryColor);
                      return;
                    }
                    final items = await Get.to(
                      () => FriendsPicker(
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
                      final user = item as IbUser;
                      if (_controller.ibChatMembers.indexWhere(
                              (element) => element.user.id == user.id) ==
                          -1) {
                        invitees.add(user);
                      }
                    }
                    await _controller.sendCircleInvites(invitees);
                  },
                  icon: const Icon(Icons.person_add_alt_1))
          ],
        ),
        body: getBody(context),
      ),
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
              _options(context),
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
              StaggeredGrid.count(
                crossAxisCount: 5,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
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
                            uid: element.user.id,
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
              const Divider(
                thickness: 2,
              ),
            ],
          ),
        ));
  }

  void _showMemberBtmSheet(IbChatMemberModel model) {
    final me = _controller.ibChatMembers.firstWhereOrNull(
        (element) => element.user.id == IbUtils.getCurrentUid()!);
    if (me == null) {
      return;
    }

    final bool isLeader = me.member.role == IbChatMember.kRoleLeader;
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
          if (isLeader && model != me)
            ListTile(
              onTap: () async {
                Get.back();
                await _controller.transferLeadership(model);
              },
              title: const Text('Transfer Leadership'),
            ),
          if (isLeader && model.member.role == IbChatMember.kRoleMember)
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
          if (isLeader && model.user.id != IbUtils.getCurrentUid())
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

    Get.bottomSheet(SafeArea(child: sheet));
  }

  Widget _options(BuildContext context) {
    return Obx(
      () => Column(
        children: [
          if (_controller.pastPolls.isNotEmpty)
            ListTile(
              onTap: () {
                Get.to(() => PastPolls(_controller));
              },
              title: const Text('View All Past Polls'),
              trailing: const Icon(
                FontAwesomeIcons.checkToSlot,
                color: IbColors.primaryColor,
              ),
            ),
          if (_controller.pastIcebreakers.isNotEmpty)
            ListTile(
              onTap: () {
                Get.to(() => PastIcebreakers(_controller));
              },
              title: const Text('View All Past Icebreakers'),
              trailing: const Text(
                '🧊',
                style: TextStyle(fontSize: 21),
              ),
            ),
          if (_controller.pastPolls.isNotEmpty ||
              _controller.pastIcebreakers.isNotEmpty)
            const Divider(
              thickness: 2,
            ),
        ],
      ),
    );
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
          if (_controller.isCircle.isFalse) {
            final member = _controller.ibChatMembers.firstWhereOrNull(
                (element) => element.user.id != IbUtils.getCurrentUid());
            if (member == null) {
              return const SizedBox();
            }
            if (IbUtils.getCurrentIbUser() == null) {
              return const SizedBox();
            }

            if (IbUtils.getCurrentIbUser()!
                .blockedFriendUids
                .contains(member.user.id)) {
              return ListTile(
                onTap: () {
                  Get.back();
                  Get.dialog(IbDialog(
                    title: 'Are you sure to unblock ${member.user.username}?',
                    subtitle: '',
                    onPositiveTap: () async {
                      Get.back();
                      await _controller.unblockUser(member.user.id);
                    },
                  ));
                },
                leading: const Icon(
                  Icons.check_circle_rounded,
                  color: IbColors.accentColor,
                ),
                title: Text.rich(
                  TextSpan(
                      text: 'Unblock ',
                      style: const TextStyle(color: IbColors.accentColor),
                      children: [
                        TextSpan(
                            text: member.user.username,
                            style: TextStyle(
                                color: Theme.of(context).indicatorColor))
                      ]),
                ),
              );
            }

            return ListTile(
              onTap: () {
                Get.back();
                Get.dialog(IbDialog(
                  title: 'Are you sure to block ${member.user.username}?',
                  subtitle:
                      'You will not able to receive messages from this user',
                  onPositiveTap: () async {
                    Get.back();
                    await _controller.blockUser(member.user.id);
                  },
                ));
              },
              leading: const Icon(
                Icons.block_flipped,
                color: IbColors.errorRed,
              ),
              title: Text.rich(
                TextSpan(
                    text: 'Block ',
                    style: const TextStyle(color: IbColors.errorRed),
                    children: [
                      TextSpan(
                          text: member.user.username,
                          style: TextStyle(
                              color: Theme.of(context).indicatorColor))
                    ]),
              ),
            );
          }
          return const SizedBox();
        }),
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
        ListTile(
          onTap: () async {
            await _controller.leaveChat();
          },
          leading: const Icon(
            FontAwesomeIcons.rightFromBracket,
            color: IbColors.errorRed,
          ),
          title: const Text(
            'Leave',
            style: TextStyle(color: IbColors.errorRed),
          ),
        ),
      ],
    );
  }
}
