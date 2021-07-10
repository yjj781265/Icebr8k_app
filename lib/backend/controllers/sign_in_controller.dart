import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class SignInController extends GetxController {
  final email = ''.obs;
  final isEmailFirstTime = true.obs;
  final isPasswordFirstTime = true.obs;
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;
  final isPwdObscured = true.obs;
  final birthdateInMs = 0.obs;
  final birthdatePickerInstructionKey = ''.obs;
  final password = ''.obs;
  final emailErrorTrKey = ''.obs;
  final passwordErrorTrKey = ''.obs;
  @override
  void onInit() {
    super.onInit();
    debounce(password, (_) => validatePassword(),
        time:
            const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis));
    debounce(
      email,
      (_) => validateEmail(),
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );
  }

  void validatePassword() {
    isPasswordFirstTime.value = false;
    isPasswordValid.value = password.value.isNotEmpty &&
        password.value.length >= IbConfig.passwordMinLength;
    print('validating password $isPasswordValid');
    if (password.value.isEmpty) {
      passwordErrorTrKey.value = 'field_is_empty';
      return;
    }

    if (password.value.length < IbConfig.passwordMinLength) {
      passwordErrorTrKey.value = '6_characters_error';
      return;
    }
    passwordErrorTrKey.value = '';
  }

  void validateEmail() {
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
}
