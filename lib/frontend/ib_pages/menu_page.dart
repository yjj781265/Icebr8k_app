import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class MenuPage extends StatelessWidget {
  MenuPage({Key? key}) : super(key: key);

  final _homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _handleAvatarImage(),
            SizedBox(
              width: 100,
              child: Obx(
                () => Text(
                  _homeController.currentIbUsername.value,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            TextButton.icon(
                onPressed: () {
                  Get.find<AuthController>().signOut();
                },
                icon: const Icon(
                  Icons.exit_to_app_outlined,
                  color: IbColors.errorRed,
                ),
                label: Text(
                  'sign_out'.tr,
                  style: const TextStyle(color: Colors.black),
                )),
          ],
        ),
      ),
    );
  }

  Widget _handleAvatarImage() {
    return Obx(() {
      final bool isEmptyUrl = _homeController.currentIbAvatarUrl.value.isEmpty;

      if (isEmptyUrl) {
        return const CircleAvatar(
            radius: 48,
            foregroundImage: AssetImage('assets/icons/logo_ios.png'));
      }
      return CircleAvatar(
        radius: 48,
        foregroundImage: NetworkImage(_homeController.currentIbAvatarUrl.value),
      );
    });
  }
}
