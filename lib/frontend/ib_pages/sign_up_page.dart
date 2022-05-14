import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';

import '../../backend/controllers/user_controllers/auth_controller.dart';
import '../../backend/controllers/user_controllers/sign_up_controller.dart';
import '../ib_utils.dart';
import 'menu_page.dart';

class SignUpPage extends GetView<SignUpController> {
  const SignUpPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Get.put(SignUpController());
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () => IbUtils.hideKeyboard(),
          child: IbCard(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Scrollbar(
                radius: const Radius.circular(IbConfig.kScrollbarCornerRadius),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                              controller.isCfPwdObscured.value = !isObscured;
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
                        () => ListTile(
                          leading: Checkbox(
                            value: controller.isOver13.value,
                            onChanged: (value) {
                              controller.isOver13.value = value ?? false;
                            },
                          ),
                          title: const Text(
                            'I am at least 13 years old',
                            style: TextStyle(
                                fontSize: IbConfig.kSecondaryTextSize),
                          ),
                        ),
                      ),
                      Obx(
                        () => ListTile(
                          leading: Checkbox(
                            value: controller.isTermRead.value,
                            onChanged: (bool? value) {
                              controller.isTermRead.value = value ?? false;
                            },
                          ),
                          title: _termPrivacyString(context),
                        ),
                      ),
                      Obx(
                        () => Hero(
                          tag: 'sign_up',
                          child: Container(
                            height: 80,
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
    );
  }

  Widget _termPrivacyString(BuildContext context) {
    const TextStyle linkStyle = TextStyle(color: Colors.blue);
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          TextSpan(
              text: 'I have read and agree to the ',
              style: TextStyle(color: Theme.of(context).indicatorColor)),
          TextSpan(
              text: 'Terms of Service',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print('Terms of Service"');
                }),
          TextSpan(
              text: ' and ',
              style: TextStyle(color: Theme.of(context).indicatorColor)),
          TextSpan(
              text: 'Privacy Policy',
              style: linkStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  print('Privacy Policy"');
                  Get.to(() => PrivacyPolicyPage());
                }),
        ],
      ),
    );
  }
}
