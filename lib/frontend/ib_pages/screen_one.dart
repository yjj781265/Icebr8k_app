import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:lottie/lottie.dart';

import '../ib_config.dart';

class ScreenOne extends StatelessWidget {
  ScreenOne({Key? key}) : super(key: key);
  final SetUpController _setUpController = Get.find();
  final TextEditingController nameEditingController = TextEditingController();
  final TextEditingController usernameEditingController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      appBar: AppBar(
        backgroundColor: IbColors.lightBlue,
        actions: [
          IconButton(
              onPressed: () async {
                await _setUpController.validateScreenOne();
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
              IbTextField(
                  controller: usernameEditingController,
                  titleIcon: const Icon(
                    Icons.tag_outlined,
                    color: IbColors.primaryColor,
                  ),
                  text: _setUpController.username.value,
                  titleTrKey: "username",
                  charLimit: IbConfig.kUsernameMaxLength,
                  hintTrKey: 'username_hint',
                  onChanged: (text) {
                    _setUpController.username.value = text;
                  }),
              IbTextField(
                controller: nameEditingController,
                titleIcon: const Icon(
                  Icons.person_outline,
                  color: IbColors.primaryColor,
                ),
                text: _setUpController.name.value,
                titleTrKey: 'name',
                hintTrKey: 'name_hint',
                textInputType: TextInputType.name,
                onChanged: (name) {
                  _setUpController.name.value = name;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
