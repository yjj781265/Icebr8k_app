import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/sign_up_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:intl/intl.dart';

import '../ib_utils.dart';

class SignUpPage extends GetView<SignUpController> {
  SignUpPage({Key? key}) : super(key: key);
  final TextEditingController _birthdateTeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(SignUpController());
    return Scaffold(
      body: GestureDetector(
        onTap: () => IbUtils.hideKeyboard(),
        child: Center(
          child: SafeArea(
            child: IbCard(
              child: SizedBox(
                width: Get.width * 0.95,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16, right: 8),
                  child: Scrollbar(
                    radius:
                        const Radius.circular(IbConfig.kScrollbarCornerRadius),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  //hide keyboard
                                  IbUtils.hideKeyboard();
                                  Get.back();
                                },
                                icon: const Icon(Icons.arrow_back_outlined),
                              ),
                              Text(
                                'sign_up'.tr,
                                style: const TextStyle(
                                    fontSize: IbConfig.kPageTitleSize,
                                    fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          Obx(
                            () => InkWell(
                              onTap: _showDateTimePicker,
                              child: IbTextField(
                                titleIcon: const Icon(
                                  Icons.cake_outlined,
                                  color: IbColors.primaryColor,
                                ),
                                borderColor:
                                    controller.isBirthDateFirstTime.value
                                        ? IbColors.lightGrey
                                        : (controller.isBirthdateValid.value
                                            ? IbColors.accentColor
                                            : IbColors.errorRed),
                                errorTrKey:
                                    controller.birthdateErrorTrKey.value,
                                controller: _birthdateTeController,
                                suffixIcon:
                                    const Icon(Icons.calendar_today_outlined),
                                titleTrKey: 'birthdate',
                                hintTrKey: 'birthdate_hint',
                                enabled: false,
                                onChanged: (birthdate) {},
                              ),
                            ),
                          ),
                          Obx(
                            () => IbTextField(
                              titleIcon: const Icon(
                                Icons.email_outlined,
                                color: IbColors.primaryColor,
                              ),
                              textInputType: TextInputType.emailAddress,
                              titleTrKey: 'email_address',
                              hintTrKey: 'email_address_hint',
                              borderColor: controller.isEmailFirstTime.value
                                  ? IbColors.lightGrey
                                  : (controller.isEmailValid.value
                                      ? IbColors.accentColor
                                      : IbColors.errorRed),
                              errorTrKey: controller.emailErrorTrKey.value,
                              onChanged: (email) {
                                controller.email.value = email.trim();
                              },
                            ),
                          ),
                          Obx(
                            () => IbTextField(
                                titleIcon: const Icon(
                                  Icons.lock_outline,
                                  color: IbColors.primaryColor,
                                ),
                                textInputType: TextInputType.visiblePassword,
                                titleTrKey: 'password',
                                hintTrKey: 'password_hint',
                                borderColor: controller.isPwdFirstTime.value
                                    ? IbColors.lightGrey
                                    : (controller.isPasswordValid.value
                                        ? IbColors.accentColor
                                        : IbColors.errorRed),
                                errorTrKey: controller.pwdErrorTrKey.value,
                                onChanged: (password) {
                                  controller.password.value = password;
                                },
                                obscureText: controller.isPwdObscured.value,
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    final bool isObscured =
                                        controller.isPwdObscured.value;
                                    controller.isPwdObscured.value =
                                        !isObscured;
                                  },
                                  icon: Icon(controller.isPwdObscured.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined),
                                )),
                          ),
                          Obx(
                            () => IbTextField(
                              titleIcon: const Icon(
                                Icons.lock_outline,
                                color: IbColors.primaryColor,
                              ),
                              textInputType: TextInputType.visiblePassword,
                              obscureText: controller.isCfPwdObscured.value,
                              suffixIcon: IconButton(
                                onPressed: () {
                                  final bool isObscured =
                                      controller.isCfPwdObscured.value;
                                  controller.isCfPwdObscured.value =
                                      !isObscured;
                                },
                                icon: Icon(controller.isCfPwdObscured.value
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined),
                              ),
                              borderColor: controller.isCfPwdFirstTime.value
                                  ? IbColors.lightGrey
                                  : (controller.isCfPwdValid.value
                                      ? IbColors.accentColor
                                      : IbColors.errorRed),
                              titleTrKey: 'confirm_password',
                              hintTrKey: 'confirm_password_hint',
                              errorTrKey: controller.confirmPwdErrorTrKey.value,
                              onChanged: (cfPwd) {
                                controller.confirmPassword.value = cfPwd;
                              },
                            ),
                          ),
                          Obx(
                            () => Hero(
                              tag: 'sign_up',
                              child: Container(
                                height: 88,
                                width: Get.width,
                                padding: const EdgeInsets.all(8),
                                child: IbElevatedButton(
                                    icon: const Icon(Icons.person_add_alt_1),
                                    textTrKey: Get.find<AuthController>()
                                            .isSigningUp
                                            .isTrue
                                        ? 'signing_up'
                                        : 'sign_up',
                                    onPressed: () {
                                      controller.signUp();
                                    }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDateTimePicker() {
    Get.bottomSheet(
        IbCard(
            child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 256,
                width: Get.width,
                child: CupertinoDatePicker(
                  initialDateTime:
                      DateTime.fromMillisecondsSinceEpoch(631170000000),
                  mode: CupertinoDatePickerMode.date,
                  onDateTimeChanged: (value) async {
                    await HapticFeedback.selectionClick();
                    _birthdateTeController.text = _readableDateTime(value);
                    controller.readableBirthdate.value =
                        _birthdateTeController.text;
                    controller.birthdateInMs.value =
                        value.millisecondsSinceEpoch;
                  },
                  dateOrder: DatePickerDateOrder.mdy,
                ),
              ),
              SizedBox(
                width: Get.width,
                child: TextButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: Text('ok'.tr),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        )),
        ignoreSafeArea: false);
  }

  String _readableDateTime(DateTime _dateTime) {
    final f = DateFormat('MM/dd/yyyy');
    return f.format(_dateTime);
  }
}
