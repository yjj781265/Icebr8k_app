import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../services/user_services/ib_local_data_service.dart';
import 'auth_controller.dart';

class SignInController extends GetxController {
  final TextEditingController emailTxtC = TextEditingController();
  final TextEditingController passwordTxtC = TextEditingController();

  final email = ''.obs;
  final isEmailFirstTime = true.obs;
  final isPasswordFirstTime = true.obs;
  final isEmailValid = true.obs;
  final isPasswordValid = true.obs;
  final isPwdObscured = true.obs;
  final password = ''.obs;
  final emailErrorTrKey = ''.obs;
  final passwordErrorTrKey = ''.obs;
  final rememberLoginEmail = false.obs;

  @override
  void onInit() {
    super.onInit();
    rememberLoginEmail.value =
        IbLocalDataService().retrieveBoolValue(StorageKey.rememberLoginEmail);

    if (rememberLoginEmail.value) {
      emailTxtC.text =
          IbLocalDataService().retrieveStringValue(StorageKey.loginEmail);
      email.value = emailTxtC.text;
    }

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
        password.value.length >= IbConfig.kPasswordMinLength;

    if (password.value.isEmpty) {
      passwordErrorTrKey.value = 'field_is_empty';
      return;
    }

    if (password.value.length < IbConfig.kPasswordMinLength) {
      passwordErrorTrKey.value = '6_characters_error';
      return;
    }
    passwordErrorTrKey.value = '';
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

  Future<void> signInViaEmail() async {
    final AuthController _authController = Get.find();
    IbUtils.hideKeyboard();
    validateEmail();
    validatePassword();
    if (isPasswordValid.isTrue && isEmailValid.isTrue) {
      await _authController.signInViaEmail(
          email: email.value,
          password: password.value,
          rememberEmail: rememberLoginEmail.value);
    }
  }
}
