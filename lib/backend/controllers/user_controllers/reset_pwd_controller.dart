import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';

import '../../managers/Ib_analytics_manager.dart';

class ResetPwdController extends GetxController {
  final email = ''.obs;
  final isEmailValid = false.obs;
  final isFirstTime = true.obs;
  final emailErrorTrKey = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debounce(
      email,
      (_) => validateEmail(),
      time: const Duration(milliseconds: IbConfig.kEventTriggerDelayInMillis),
    );
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'ResetPwdController', screenName: 'ResetPwdPage');
  }

  void validateEmail() {
    isFirstTime.value = false;
    email.value = email.value.trim();
    isEmailValid.value = GetUtils.isEmail(email.value.trim());
    print('validating reset email $isEmailValid');
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

  void reset() {
    isFirstTime.value = true;
    emailErrorTrKey.value = '';
    email.value = '';
  }
}
