import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../services/user_services/ib_local_data_service.dart';
import 'auth_controller.dart';

class SignInController extends GetxController {
  final TextEditingController emailTxtC = TextEditingController();
  final TextEditingController passwordTxtC = TextEditingController();
  final AuthController authController;
  final IbUtils utils;
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

  SignInController({required this.authController, required this.utils});

  @override
  void onInit() {
    super.onInit();
    rememberLoginEmail.value = IbLocalDataService()
        .retrieveBoolValue(StorageKey.rememberLoginEmailBool);

    if (rememberLoginEmail.value) {
      emailTxtC.text =
          IbLocalDataService().retrieveStringValue(StorageKey.loginEmailString);
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

  @override
  Future<void> onReady() async {
    await IbAnalyticsManager()
        .logScreenView(className: 'SignInController', screenName: 'SignInPage');
    super.onReady();
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
    utils.hideKeyboard();
    validateEmail();
    validatePassword();
    if (isPasswordValid.isTrue && isEmailValid.isTrue) {
      await authController.signInViaEmail(
          email: email.value,
          password: password.value,
          rememberEmail: rememberLoginEmail.value);
    }
  }
}
