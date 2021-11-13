import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/reset_pwd_controller.dart';
import 'package:icebr8k/backend/controllers/sign_in_controller.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/sign_up_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_simple_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_single_date_picker.dart';
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
                    const SizedBox(
                      height: 64,
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
                                    fontWeight: FontWeight.w700,
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
                              () => IbElevatedButton(
                                textTrKey: _authController.isSigningIn.isTrue
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
                            /**** Signup Button ****/
                            InkWell(
                              onTap: () async {
                                //hide keyboard
                                IbUtils.hideKeyboard();
                                //result from SignUp Page
                                final result = await Get.to(SignUpPage());
                                if (result != null) {
                                  final List<String> _list =
                                      result as List<String>;
                                  _emailTxtC.text = _list.first;
                                  _passwordTxtC.text = _list[1];
                                  _controller.email.value = _list.first;
                                  _controller.password.value = _list[1];
                                }
                              },
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
                                        ),
                                      ),
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
                              margin: const EdgeInsets.only(
                                  left: 50.0, right: 20.0),
                              child: const Divider(
                                color: IbColors.lightGrey,
                                thickness: 1,
                              )),
                        ),
                        Text(
                          "or".tr,
                          style: const TextStyle(
                              fontSize: IbConfig.kSecondaryTextSize,
                              color: IbColors.lightGrey),
                        ),
                        Expanded(
                          child: Container(
                            margin:
                                const EdgeInsets.only(left: 20.0, right: 50.0),
                            child: const Divider(
                              color: IbColors.lightGrey,
                              thickness: 1,
                            ),
                          ),
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
                            onPressed: () {
                              checkThirdPartyLoginAge(
                                  _authController.signInViaGoogle);
                            },
                          ),

                          //Todo currently Apple auth is not supported in Android
                          if (GetPlatform.isIOS)
                            SignInButton(
                              Buttons.Apple,
                              onPressed: () {
                                checkThirdPartyLoginAge(
                                    _authController.signInViaApple);
                              },
                            ),
                        ],
                      ),
                    )
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

  void checkThirdPartyLoginAge(Function _isOver13Func) {
    _controller.birthdatePickerInstructionKey.value = 'date_picker_instruction';
    _controller.birthdateInMs.value = 0;
    Get.dialog(
        Obx(
          () => IbSingleDatePicker(
            onSelectionChanged: (arg) {
              _controller.birthdateInMs.value =
                  (arg.value as DateTime).millisecondsSinceEpoch;
              _controller.birthdatePickerInstructionKey.value = '';
            },
            titleTrKey: _controller.birthdatePickerInstructionKey.value,
            buttons: [
              TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'cancel'.tr,
                    style: const TextStyle(color: IbColors.errorRed),
                  )),
              TextButton(
                  onPressed: () async {
                    if (_controller
                        .birthdatePickerInstructionKey.value.isNotEmpty) {
                      return;
                    }

                    Get.back();

                    if (IbUtils.isOver13(
                      DateTime.fromMillisecondsSinceEpoch(
                          _controller.birthdateInMs.value),
                    )) {
                      _isOver13Func();
                    } else {
                      Get.dialog(IbSimpleDialog(
                          message: 'age_limit_msg'.tr,
                          positiveBtnTrKey: 'ok'.tr));
                    }
                  },
                  child: Text('confirm'.tr))
            ],
          ),
        ),
        barrierDismissible: false);
  }
}
