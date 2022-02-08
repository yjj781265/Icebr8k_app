import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/admin_main_controller.dart';
import 'package:icebr8k/frontend/admin/pending_app_main_page.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';

class AdminMainPage extends StatelessWidget {
  final AdminMainController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                          textTrKey: 'Applications',
                          onPressed: () {
                            Get.to(() => PendingAppMainPage());
                          },
                          color: IbColors.primaryColor,
                        )),
                    Positioned(
                      top: -8,
                      right: 3,
                      child: CircleAvatar(
                        backgroundColor: IbColors.errorRed,
                        child: Text(_controller.pendingUsers.length.toString()),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
