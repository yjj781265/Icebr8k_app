import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/admin_main_controller.dart';
import 'package:icebr8k/frontend/admin/admin_main_page.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';

import '../../backend/controllers/user_controllers/auth_controller.dart';

class RoleSelectPage extends StatelessWidget {
  final AdminMainController _controller = Get.put(AdminMainController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              children: [
                IbActionButton(
                  color: IbColors.primaryColor,
                  iconData: FontAwesomeIcons.chessKing,
                  onPressed: () {
                    Get.to(() => AdminMainPage());
                  },
                  text: "Admin",
                  size: 48,
                ),
                Obx(() {
                  if (_controller.totalMessages > 0) {
                    return Positioned(
                      top: 2,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: IbColors.errorRed,
                        radius: 11,
                        child: Text(
                          _controller.totalMessages >= 99
                              ? '99+'
                              : _controller.totalMessages.toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: IbColors.white,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            IbActionButton(
              color: IbColors.accentColor,
              iconData: FontAwesomeIcons.user,
              onPressed: () async {
                _controller.onUserRoleTap();
              },
              text: "User",
              size: 48,
            ),
            const SizedBox(
              height: 64,
            ),
            InkWell(
              onLongPress: () async {
                await Get.find<AuthController>().signOut();
              },
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
          ],
        ),
      )),
    );
  }
}
