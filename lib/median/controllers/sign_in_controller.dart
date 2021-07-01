import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class SignInController extends GetxController {
  final email = ''.obs;
  final isEmailFirstTime = true.obs;
  final isPasswordFirstTime = true.obs;
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;
  final isPwdObscured = true.obs;
  final password = ''.obs;
  final emailErrorTrKey = ''.obs;
  final passwordErrorTrKey = ''.obs;
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
  }

  void _validatePassword() {
    isPasswordFirstTime.value = false;
    isPasswordValid.value =
        password.value.isNotEmpty && password.value.length >= 8;
    print('validating password $isPasswordValid');
    if (password.value.isEmpty) {
      passwordErrorTrKey.value = 'field_is_empty';
      return;
    }

    if (password.value.length < 8) {
      passwordErrorTrKey.value = '8_characters_error';
      return;
    }
    passwordErrorTrKey.value = '';
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
}
