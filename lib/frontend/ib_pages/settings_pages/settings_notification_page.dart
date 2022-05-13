import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/backend/models/ib_settings.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

class SettingsNotificationPage extends StatelessWidget {
  final MainPageController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    _controller.rxCurrentIbUser.value.settings ??= IbSettings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: Obx(
        () => ListView(
          children: [
            SwitchListTile.adaptive(
              value: _controller.rxCurrentIbUser.value.settings!.friendRequestN,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!.friendRequestN =
                    value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              title: const Text('New Friend Requests'),
            ),
            SwitchListTile.adaptive(
              value: _controller.rxCurrentIbUser.value.settings!.pollCommentN,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!.pollCommentN =
                    value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              title: const Text('New Comments on Polls'),
            ),
            SwitchListTile.adaptive(
              value:
                  _controller.rxCurrentIbUser.value.settings!.pollCommentLikesN,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!.pollCommentLikesN =
                    value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              title: const Text("New Likes on Comments"),
            ),
            SwitchListTile.adaptive(
              value: _controller.rxCurrentIbUser.value.settings!.pollLikesN,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!.pollLikesN = value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              title: const Text('New Likes on Polls'),
            ),
            SwitchListTile.adaptive(
              value: _controller.rxCurrentIbUser.value.settings!.pollVoteN,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!.pollVoteN = value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              title: const Text('New Votes on Polls'),
            ),
            SwitchListTile.adaptive(
              value: _controller.rxCurrentIbUser.value.settings!.circleInviteN,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!.circleInviteN =
                    value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              subtitle: const Text(
                'You will get notified whenever someone invites you to join a circle',
                style: TextStyle(color: IbColors.lightGrey),
              ),
              title: const Text('New Circle Invite'),
            ),
            SwitchListTile.adaptive(
              value: _controller.rxCurrentIbUser.value.settings!.circleRequestN,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!.circleRequestN =
                    value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              subtitle: const Text(
                  'You will get notified whenever someone requested to join one of your private circles',
                  style: TextStyle(color: IbColors.lightGrey)),
              title: const Text(
                'New Circle Join Request',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
