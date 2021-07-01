import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:icebr8k/median/controllers/sign_up_controller.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../ib_utiis.dart';

class SignUpPage extends GetView<SignUpController> {
  SignUpPage({Key? key}) : super(key: key);
  final TextEditingController _birthdateTeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Get.put(SignUpController());
    return Scaffold(
      backgroundColor: IbColors.primaryColor,
      body: GestureDetector(
        onTap: () => IbUtils.hideKeyboard(),
        child: Center(
          child: IbCard(
            child: SizedBox(
              width: Get.width * 0.95,
              height: Get.height * 0.8,
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
                          () => IbTextField(
                            titleIcon: const Icon(
                              Icons.person_outline,
                              color: IbColors.primaryColor,
                            ),
                            titleTrKey: 'name',
                            hintTrKey: 'name_hint',
                            textInputType: TextInputType.name,
                            errorTrKey: controller.nameErrorTrKey.value,
                            borderColor: controller.isNameFirstTime.value
                                ? IbColors.lightGrey
                                : (controller.isNameValid.value
                                    ? IbColors.accentColor
                                    : IbColors.errorRed),
                            onChanged: (name) {
                              controller.name.value = name;
                            },
                          ),
                        ),
                        Obx(
                          () => InkWell(
                            onTap: () => showDialog(
                                context: context,
                                builder: (context) => _getDatePicker()),
                            child: IbTextField(
                              titleIcon: const Icon(
                                Icons.cake_outlined,
                                color: IbColors.primaryColor,
                              ),
                              borderColor: controller.isBirthDateFirstTime.value
                                  ? IbColors.lightGrey
                                  : (controller.isBirthdateValid.value
                                      ? IbColors.accentColor
                                      : IbColors.errorRed),
                              errorTrKey: controller.birthdateErrorTrKey.value,
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
                                  controller.isPwdObscured.value = !isObscured;
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
                                controller.isPwdObscured.value = !isObscured;
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
                        IbElevatedButton(
                            textTrKey: 'sign_up',
                            onPressed: () => print("to home page")),
                      ],
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

  Widget _getDatePicker() {
    controller.birthdatePickerInstructionKey.value = 'birthdate_instruction';
    return Obx(
      () => Center(
        child: SizedBox(
          width: Get.width * 0.95,
          height: 400,
          child: IbCard(
              child: Column(
            children: [
              SfDateRangePicker(
                initialDisplayDate: DateTime(1990),
                showNavigationArrow: true,
                maxDate: DateTime.now(),
                view: DateRangePickerView.decade,
                headerStyle: const DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center),
                onSelectionChanged: (arg) {
                  print(arg.value as DateTime);
                  controller.birthdateInMillis.value =
                      (arg.value as DateTime).millisecondsSinceEpoch;
                  controller.birthdatePickerInstructionKey.value = '';
                },
                monthViewSettings:
                    const DateRangePickerMonthViewSettings(firstDayOfWeek: 1),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      onPressed: () => Get.back(), child: Text('cancel'.tr)),
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: TextButton(
                        onPressed: () {
                          if (controller
                              .birthdatePickerInstructionKey.value.isNotEmpty) {
                            return;
                          }

                          final _dateTime = DateTime.fromMillisecondsSinceEpoch(
                              controller.birthdateInMillis.value);
                          controller.readableBirthdate.value =
                              _readableDateTime(_dateTime);
                          _birthdateTeController.text =
                              controller.readableBirthdate.value;
                          print(_readableDateTime(_dateTime));
                          Get.back();
                        },
                        child: Text('confirm'.tr)),
                  ),
                ],
              ),
              Text(
                controller.birthdatePickerInstructionKey.value.tr,
                style: const TextStyle(color: IbColors.errorRed),
              ),
            ],
          )),
        ),
      ),
    );
  }

  String _readableDateTime(DateTime _dateTime) {
    final f = DateFormat('MM/dd/yyyy');
    return f.format(_dateTime);
  }
}
