import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class SignUpController extends GetxController {
  final name = ''.obs;
  final nameErrorTrKey = ''.obs;
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
      name,
      (_) => _validateName(),
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

  void _validateName() {
    isNameFirstTime.value = false;
    isNameValid.value = name.value.isNotEmpty;
    print('validating name ${isNameValid.value}');

    if (name.value.isEmpty) {
      nameErrorTrKey.value = 'field_is_empty';
      return;
    }

    nameErrorTrKey.value = '';
  }

  void _validateBirthdate() {
    final date = DateTime.fromMillisecondsSinceEpoch(birthdateInMs.value);
    // 13 years is roughly 4745 days
    final bool isOver13 = IbUtils.isOver13(date);
    isBirthDateFirstTime.value = false;
    isBirthdateValid.value = readableBirthdate.value.isNotEmpty && isOver13;
    print('validating birthdate ${isBirthdateValid.value}');

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
    isPasswordValid.value =
        password.value.isNotEmpty && password.value.length >= 8;
    print('validating password $isPasswordValid');

    if (password.value.isEmpty) {
      pwdErrorTrKey.value = 'field_is_empty';
      return;
    }

    if (password.value.length < 8) {
      pwdErrorTrKey.value = '8_characters_error';
      return;
    }
    pwdErrorTrKey.value = '';
  }

  void _validateCfPassword() {
    isCfPwdFirstTime.value = false;
    isCfPwdValid.value = confirmPassword.value.isNotEmpty &&
        confirmPassword.value.length >= 8 &&
        confirmPassword.value == password.value;
    print('validating confirmPassword $isCfPwdValid');
    if (confirmPassword.value.isEmpty) {
      confirmPwdErrorTrKey.value = 'field_is_empty';
      return;
    }

    if (confirmPassword.value.length < 8) {
      confirmPwdErrorTrKey.value = '8_characters_error';
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
    print('validating email $isEmailValid');
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
    _validateName();
    _validateEmail();
    _validatePassword();
    _validateBirthdate();
  }

  bool isEverythingValid() {
    return isNameValid.isTrue &&
        isBirthdateValid.isTrue &&
        isEmailValid.isTrue &&
        isCfPwdValid.isTrue &&
        isPasswordValid.isTrue;
  }

  @override
  String toString() {
    return 'SignUpController{name: $name, birthdateInMillis: $birthdateInMs, '
        'email: $email, password: $password, confirmPassword: $confirmPassword}';
  }
}
