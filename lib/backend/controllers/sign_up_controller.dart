import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class SignUpController extends GetxController {
  final birthdateInMs = 0.obs;
  final readableBirthdate = ''.obs;
  final birthdatePickerInstructionKey = 'birthdate_instruction'.obs;
  final birthdateErrorTrKey = ''.obs;
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
  final isBirthDateFirstTime = true.obs;
  final isPasswordValid = false.obs;
  final isCfPwdValid = false.obs;
  final isEmailValid = false.obs;
  final isNameValid = false.obs;
  final isBirthdateValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(password, (_) => _validatePassword(),
        time:
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
    debounce(
      email,
      (_) => _validateEmail(),
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );

    debounce(
      readableBirthdate,
      (_) => _validateBirthdate(),
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );
    debounce(
      confirmPassword,
      (_) => _validateCfPassword(),
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );
  }

  void _validateBirthdate() {
    final date = DateTime.fromMillisecondsSinceEpoch(birthdateInMs.value);
    // 13 years is roughly 4745 days
    final bool isOver13 = IbUtils.isOver13(date);
    isBirthDateFirstTime.value = false;
    isBirthdateValid.value = readableBirthdate.value.isNotEmpty && isOver13;

    if (readableBirthdate.value.isEmpty) {
      birthdateErrorTrKey.value = 'field_is_empty';
      return;
    }

    if (!isOver13) {
      birthdateErrorTrKey.value = 'age_limit_msg';
      return;
    }

    birthdateErrorTrKey.value = '';
  }

  void _validatePassword() {
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

  void _validateCfPassword() {
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

  void _validateEmail() {
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

  void validateAllFields() {
    _validateCfPassword();
    _validateEmail();
    _validatePassword();
    _validateBirthdate();
  }

  bool isEverythingValid() {
    return isBirthdateValid.isTrue &&
        isEmailValid.isTrue &&
        isCfPwdValid.isTrue &&
        isPasswordValid.isTrue;
  }

  @override
  String toString() {
    return 'SignUpController{ birthdateInMillis: $birthdateInMs, '
        'email: $email, password: $password, confirmPassword: $confirmPassword}';
  }
}
