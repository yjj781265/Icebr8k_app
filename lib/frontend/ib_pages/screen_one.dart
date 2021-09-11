import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:lottie/lottie.dart';

import '../ib_config.dart';

class ScreenOne extends StatelessWidget {
  ScreenOne({Key? key}) : super(key: key);
  final SetUpController _setUpController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: 48, left: 24, right: 24, bottom: 16),
              child: Text(
                'slogan_one'.tr,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 36,
                ),
              ),
            ),
            SizedBox(
                width: 230,
                height: 230,
                child: Lottie.asset('assets/images/business_chat.json')),
            Obx(
              () => IbTextField(
                  titleIcon: const Icon(
                    Icons.tag_outlined,
                    color: IbColors.primaryColor,
                  ),
                  titleTrKey: "username",
                  charLimit: IbConfig.kUsernameMaxLength,
                  errorTrKey: _setUpController.usernameErrorTrKey.value,
                  borderColor: _setUpController.isUsernameFirstTime.isTrue
                      ? IbColors.lightGrey
                      : _setUpController.isUsernameValid.isTrue
                          ? IbColors.accentColor
                          : IbColors.errorRed,
                  hintTrKey: 'username_hint',
                  onChanged: (text) {
                    _setUpController.username.value = text;
                  }),
            ),
            Obx(
              () => IbTextField(
                titleIcon: const Icon(
                  Icons.person_outline,
                  color: IbColors.primaryColor,
                ),
                titleTrKey: 'name',
                hintTrKey: 'name_hint',
                textInputType: TextInputType.name,
                errorTrKey: _setUpController.nameErrorTrKey.value,
                borderColor: _setUpController.isNameFirstTime.value
                    ? IbColors.lightGrey
                    : (_setUpController.isNameValid.value
                        ? IbColors.accentColor
                        : IbColors.errorRed),
                onChanged: (name) {
                  _setUpController.name.value = name;
                },
              ),
            ),
            IbActionButton(
                color: IbColors.accentColor,
                iconData: Icons.arrow_forward_outlined,
                onPressed: () {
                  _setUpController.liquidController.animateToPage(
                      page: _setUpController.liquidController.currentPage + 1);
                },
                text: ''),
            const SizedBox(
              height: 36,
            ),
            TextButton(
              onPressed: () {
                Get.find<AuthController>().signOut();
              },
              child: Text('sign_out'.tr),
            )
          ],
        ),
      ),
    );
  }
}
