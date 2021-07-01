import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/sign_up_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:icebr8k/median/controllers/sign_in_controller.dart';

class SignInPage extends GetView<SignInController> {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: IbColors.primaryColor),
    );
    Get.put(SignInController());
    return Scaffold(
      backgroundColor: IbColors.primaryColor,
      body: Scrollbar(
        radius: const Radius.circular(IbConfig.kScrollbarCornerRadius),
        child: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 64, 0, 16),
                  child: Image.asset(
                    'assets/images/ib_banner_white.png',
                    width: Get.width * 0.7,
                  ),
                ),
                IbCard(
                  child: SizedBox(
                    width: Get.width * 0.95,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "welcome_msg".tr,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: IbConfig.kPageTitleSize),
                          ),
                        ),
                        Text(
                          'welcome_msg_desc'.tr,
                          style: const TextStyle(
                              fontSize: IbConfig.kDescriptionTextSize,
                              color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 32,
                        ),

                        /*********** Email text field *********/
                        Obx(() => IbTextField(
                            textInputType: TextInputType.emailAddress,
                            titleIcon: const Icon(
                              Icons.email_outlined,
                              color: IbColors.primaryColor,
                            ),
                            autofillHints: const [
                              AutofillHints.email,
                              AutofillHints.username
                            ],
                            onChanged: (text) {
                              controller.email.value = text;
                            },
                            borderColor: controller.isEmailFirstTime.value
                                ? IbColors.lightGrey
                                : (controller.isEmailValid.value
                                    ? IbColors.accentColor
                                    : IbColors.errorRed),
                            titleTrKey: 'email_address',
                            hintTrKey: 'email_address_hint',
                            errorTrKey: controller.emailErrorTrKey.value)),

                        /********* password textInputBox **********/
                        Obx(() => IbTextField(
                            titleIcon: const Icon(
                              Icons.lock_outline,
                              color: IbColors.primaryColor,
                            ),
                            autofillHints: const [AutofillHints.password],
                            obscureText: controller.isPwdObscured.value,
                            onChanged: (text) {
                              controller.password.value = text;
                            },
                            borderColor: controller.isPasswordFirstTime.value
                                ? IbColors.lightGrey
                                : (controller.isPasswordValid.value
                                    ? IbColors.accentColor
                                    : IbColors.errorRed),
                            suffixIcon: IconButton(
                              onPressed: () {
                                final bool isObscured =
                                    controller.isPwdObscured.value;
                                controller.isPwdObscured.value = !isObscured;
                              },
                              icon: Icon(controller.isPwdObscured.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined),
                            ),
                            titleTrKey: 'password',
                            hintTrKey: 'password_hint',
                            errorTrKey: controller.passwordErrorTrKey.value)),

                        /**** forgot password ****/
                        Padding(
                          padding: const EdgeInsets.only(left: 24),
                          child: Row(
                            children: [
                              TextButton(
                                  style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero),
                                  onPressed: () => print('pressed'),
                                  child: Text(
                                    'forget_pwd'.tr,
                                    style: const TextStyle(
                                        color: IbColors.lightGrey,
                                        fontSize: IbConfig.kSecondaryTextSize),
                                  )),
                            ],
                          ),
                        ),
                        IbElevatedButton(
                          textTrKey: 'login',
                          onPressed: () {
                            print(
                                "${controller.email.value.trim()} , ${controller.password.value}");
                          },
                        ),
                        InkWell(
                          onTap: () => Get.to(SignUpPage()),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text.rich(
                              TextSpan(
                                text: 'new_here'.tr,
                                style: const TextStyle(
                                    fontSize: IbConfig.kSecondaryTextSize,
                                    color: IbColors.primaryColor),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: 'sign_up'.tr,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                      )),
                                  // can add more TextSpans here...
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          margin:
                              const EdgeInsets.only(left: 50.0, right: 20.0),
                          child: const Divider(
                            color: IbColors.white,
                            thickness: 1,
                          )),
                    ),
                    Text(
                      "or".tr,
                      style: const TextStyle(
                          fontSize: IbConfig.kSecondaryTextSize,
                          color: IbColors.white),
                    ),
                    Expanded(
                      child: Container(
                          margin:
                              const EdgeInsets.only(left: 20.0, right: 50.0),
                          child: const Divider(
                            color: IbColors.white,
                            thickness: 1,
                          )),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),

                /**** Third party sign in options ****/
                Padding(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    children: [
                      SignInButton(
                        Buttons.Google,
                        onPressed: () {},
                      ),
                      SignInButton(
                        Buttons.Apple,
                        onPressed: () {},
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
