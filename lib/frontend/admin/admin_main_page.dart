import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/admin_main_controller.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/frontend/admin/pending_app_main_page.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';

import '../ib_utils.dart';

class AdminMainPage extends StatelessWidget {
  final AdminMainController _controller = Get.put(AdminMainController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Admin Main Page'),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 32,
            ),
            Obx(
              () => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: IbElevatedButton(
                          textTrKey: 'Pending Applications',
                          onPressed: () {
                            Get.to(() => PendingAppMainPage());
                          },
                          color: IbColors.primaryColor,
                        )),
                    if (_controller.pendingUsers.isNotEmpty)
                      Positioned(
                        top: -8,
                        right: 3,
                        child: CircleAvatar(
                          radius: 11,
                          backgroundColor: IbColors.errorRed,
                          child: Text(
                            _controller.pendingUsers.length.toString(),
                            style: const TextStyle(
                                fontSize: IbConfig.kSecondaryTextSize),
                          ),
                        ),
                      )
                  ],
                ),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomCenter,
              child: InkWell(
                onLongPress: () async {
                  await Get.find<AuthController>().signOut();
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IbActionButton(
                    color: IbColors.errorRed,
                    iconData: FontAwesomeIcons.signOutAlt,
                    onPressed: () {
                      IbUtils.showSimpleSnackBar(
                          msg: 'Long press to sign out',
                          backgroundColor: IbColors.primaryColor);
                    },
                    text: "Sign out",
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
