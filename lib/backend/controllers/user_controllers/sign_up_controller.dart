import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';

import 'auth_controller.dart';

class SignUpController extends GetxController {
  final email = ''.obs;
  final emailErrorTrKey = ''.obs;
  final password = ''.obs;
  final pwdErrorTrKey = ''.obs;
  final confirmPassword = ''.obs;
  final confirmPwdErrorTrKey = ''.obs;
  final isCfPwdObscured = true.obs;
  final isPwdObscured = true.obs;
  final isNameFirstTime = true.obs;
  final isPwdFirstTime = true.obs;
  final isCfPwdFirstTime = true.obs;
  final isEmailFirstTime = true.obs;
  final isPasswordValid = false.obs;
  final isCfPwdValid = false.obs;
  final isEmailValid = false.obs;
  final isNameValid = false.obs;
  final isOver13 = false.obs;
  final isTermRead = false.obs;
  final IbUtils ibUtils;
  final AuthController authController;

  SignUpController(this.ibUtils, this.authController);

  @override
  void onInit() {
    super.onInit();
    debounce(password, (_) {
      validateCfPassword();
      validatePassword();
    }, time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
    debounce(
      email,
      (_) => validateEmail(),
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );

    debounce(
      confirmPassword,
      (_) {
        validateCfPassword();
        validatePassword();
      },
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );
  }

  @override
  Future<void> onReady() async {
    await IbAnalyticsManager()
        .logScreenView(className: 'SignUpController', screenName: 'SignUpPage');
    super.onReady();
  }

  void validatePassword() {
    isPwdFirstTime.value = false;
    isPasswordValid.value = password.value.isNotEmpty &&
        password.value.length >= IbConfig.kPasswordMinLength;

    if (password.value.isEmpty) {
      pwdErrorTrKey.value = 'field_is_empty';
      return;
    }

    if (password.value.length < IbConfig.kPasswordMinLength) {
      pwdErrorTrKey.value = '6_characters_error';
      return;
    }
    pwdErrorTrKey.value = '';
  }

  void validateCfPassword() {
    isCfPwdFirstTime.value = false;
    isCfPwdValid.value = confirmPassword.value.isNotEmpty &&
        confirmPassword.value.length >= IbConfig.kPasswordMinLength &&
        confirmPassword.value == password.value;

    if (confirmPassword.value.isEmpty) {
      confirmPwdErrorTrKey.value = 'field_is_empty';
      return;
    }

    if (confirmPassword.value.length < IbConfig.kPasswordMinLength) {
      confirmPwdErrorTrKey.value = '6_characters_error';
      return;
    }
    if (confirmPassword.value != password.value) {
      confirmPwdErrorTrKey.value = 'password_match_error';
      return;
    }
    confirmPwdErrorTrKey.value = '';
  }

  void validateEmail() {
    isEmailFirstTime.value = false;
    email.value = email.value.trim();
    isEmailValid.value = GetUtils.isEmail(email.value.trim());

    if (email.value.isEmpty) {
      emailErrorTrKey.value = 'field_is_empty';
      return;
    }
    if (!isEmailValid.value) {
      emailErrorTrKey.value = 'email_not_valid';
      return;
    }
    emailErrorTrKey.value = '';
  }

  void validateCheckBox() {
    if (isOver13.isFalse) {
      ibUtils.showDialog(const IbDialog(
        showNegativeBtn: false,
        title: 'Age Check',
        subtitle:
            "Please check the checkbox to confirm you are over 13 years old",
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (isTermRead.isFalse) {
      ibUtils.showDialog(const IbDialog(
        showNegativeBtn: false,
        title: 'Terms of Service and Privacy Policy',
        subtitle:
            "Please check the checkbox to agree our Term of Service and Privacy Policy",
        positiveTextKey: 'ok',
      ));
      return;
    }

    isOver13.value = true;
    isTermRead.value = true;
  }

  void validateAllFields() {
    validateCfPassword();
    validateEmail();
    validatePassword();
    validateCheckBox();
  }

  bool isEverythingValid() {
    return isEmailValid.isTrue &&
        isCfPwdValid.isTrue &&
        isPasswordValid.isTrue &&
        isTermRead.isTrue &&
        isOver13.isTrue;
  }

  Future<void> signUp() async {
    ibUtils.hideKeyboard();
    validateAllFields();
    if (isEverythingValid()) {
      await authController.signUpViaEmail(email.value, password.value);
    }
  }
}
