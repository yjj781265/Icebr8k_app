import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/reset_pwd_controller.dart';
import 'package:icebr8k/backend/controllers/sign_in_controller.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field_dialog.dart';

class SignInPage extends StatelessWidget {
  SignInPage({Key? key}) : super(key: key);
  final TextEditingController _emailTxtC = TextEditingController();
  final TextEditingController _passwordTxtC = TextEditingController();
  final ResetPwdController _resetPwdController = Get.put(ResetPwdController());
  final SignInController _controller = Get.put(SignInController());
  final AuthController _authController = Get.find();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
          statusBarColor: !IbLocalStorageService()
                  .isCustomKeyTrue(IbLocalStorageService.isLightModeCustomKey)
              ? Colors.black
              : IbColors.lightBlue),
    );
    return Scaffold(
      body: GestureDetector(
        onTap: () => IbUtils.hideKeyboard(),
        child: Scrollbar(
          radius: const Radius.circular(IbConfig.kScrollbarCornerRadius),
          child: Center(
            child: SingleChildScrollView(
              child: AutofillGroup(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IbCard(
                      child: SizedBox(
                        width: Get.width * 0.95,
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
                                  'login'.tr,
                                  style: const TextStyle(
                                      fontSize: IbConfig.kPageTitleSize,
                                      fontWeight: FontWeight.bold),
                                )
                              ],
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
                                controller: _emailTxtC,
                                onChanged: (text) {
                                  _controller.email.value = text;
                                },
                                borderColor: _controller.isEmailFirstTime.value
                                    ? IbColors.lightGrey
                                    : (_controller.isEmailValid.value
                                        ? IbColors.accentColor
                                        : IbColors.errorRed),
                                titleTrKey: 'email_address',
                                hintTrKey: 'email_address_hint',
                                errorTrKey: _controller.emailErrorTrKey.value)),

                            /********* password textInputBox **********/
                            Obx(() => IbTextField(
                                titleIcon: const Icon(
                                  Icons.lock_outline,
                                  color: IbColors.primaryColor,
                                ),
                                controller: _passwordTxtC,
                                autofillHints: const [AutofillHints.password],
                                obscureText: _controller.isPwdObscured.value,
                                onChanged: (text) {
                                  _controller.password.value = text;
                                },
                                borderColor:
                                    _controller.isPasswordFirstTime.value
                                        ? IbColors.lightGrey
                                        : (_controller.isPasswordValid.value
                                            ? IbColors.accentColor
                                            : IbColors.errorRed),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    final bool isObscured =
                                        _controller.isPwdObscured.value;
                                    _controller.isPwdObscured.value =
                                        !isObscured;
                                  },
                                  icon: Icon(_controller.isPwdObscured.value
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined),
                                ),
                                titleTrKey: 'password',
                                hintTrKey: 'password_hint',
                                errorTrKey:
                                    _controller.passwordErrorTrKey.value)),

                            /**** forgot password ****/
                            Padding(
                              padding: const EdgeInsets.only(left: 24),
                              child: Row(
                                children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero),
                                    onPressed: () {
                                      _resetPwdController.reset();
                                      Get.bottomSheet(
                                        Obx(
                                          () => IbTextFieldDialog(
                                            textInputType:
                                                TextInputType.emailAddress,
                                            buttons: [
                                              TextButton(
                                                  onPressed: () {
                                                    Get.back();
                                                  },
                                                  child: Text(
                                                    'cancel'.tr,
                                                    style: const TextStyle(
                                                        color:
                                                            IbColors.errorRed),
                                                  )),
                                              TextButton(
                                                  onPressed: _resetPassword,
                                                  child: Text('reset_pwd'.tr)),
                                            ],
                                            borderColor: _resetPwdController
                                                    .isFirstTime.value
                                                ? IbColors.lightGrey
                                                : (_resetPwdController
                                                        .isEmailValid.value
                                                    ? IbColors.accentColor
                                                    : IbColors.errorRed),
                                            introTrKey: 'reset_email_intro',
                                            titleIcon: const Icon(
                                              Icons.email_outlined,
                                              color: IbColors.primaryColor,
                                            ),
                                            errorTrKey: _resetPwdController
                                                .emailErrorTrKey.value,
                                            titleTrKey: 'email_address',
                                            hintTrKey: 'email_address_hint',
                                            onChanged: (text) {
                                              _resetPwdController.email.value =
                                                  text.trim();
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      'forget_pwd'.tr,
                                      style: const TextStyle(
                                          color: IbColors.lightGrey,
                                          fontSize:
                                              IbConfig.kSecondaryTextSize),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            /**** Login Button ****/
                            Obx(
                              () => Hero(
                                transitionOnUserGestures: true,
                                tag: 'login',
                                child: Container(
                                  height: 88,
                                  width: Get.width,
                                  padding: const EdgeInsets.all(8),
                                  child: IbElevatedButton(
                                    icon:
                                        const Icon(FontAwesomeIcons.signInAlt),
                                    color: IbColors.primaryColor,
                                    textTrKey:
                                        _authController.isSigningIn.isTrue
                                            ? 'signing_in'
                                            : 'login',
                                    onPressed: () async {
                                      IbUtils.hideKeyboard();
                                      _controller.validateEmail();
                                      _controller.validatePassword();
                                      if (_controller.isPasswordValid.isTrue &&
                                          _controller.isEmailValid.isTrue) {
                                        await _authController.signInViaEmail(
                                            _controller.email.value,
                                            _controller.password.value);
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _resetPassword() async {
    _resetPwdController.validateEmail();
    if (_resetPwdController.isEmailValid.isTrue) {
      Get.back();
      IbUtils.hideKeyboard();
      await _authController
          .resetPassword(_resetPwdController.email.value.trim());
    }
  }
}
