import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/main_page_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';

import '../../../backend/models/ib_settings.dart';
import '../../../backend/services/user_services/ib_user_db_service.dart';

class SettingsPollPage extends StatelessWidget {
  final MainPageController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    _controller.rxCurrentIbUser.value.settings ??= IbSettings();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Settings'),
      ),
      body: Obx(
        () => ListView(
          children: [
            SwitchListTile.adaptive(
              value: _controller
                  .rxCurrentIbUser.value.settings!.pollExpandedByDefault,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!
                    .pollExpandedByDefault = value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              title: const Text('Expand Poll by Default'),
              subtitle: const Text(
                'Take effect after restarting the app',
                style: TextStyle(
                    fontSize: IbConfig.kSecondaryTextSize,
                    color: IbColors.lightGrey),
              ),
            ),
            SwitchListTile.adaptive(
              value: _controller
                  .rxCurrentIbUser.value.settings!.voteAnonymousByDefault,
              onChanged: (value) async {
                _controller.rxCurrentIbUser.value.settings!
                    .voteAnonymousByDefault = value;
                await IbUserDbService()
                    .updateIbUser(_controller.rxCurrentIbUser.value);
              },
              title: const Text('Vote Anonymously By Default'),
            ),
          ],
        ),
      ),
    );
  }
}
