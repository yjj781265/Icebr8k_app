import 'package:flutter_test/flutter_test.dart';
import 'package:icebr8k/backend/controllers/user_controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/sign_up_controller.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_up_controller_test.mocks.dart';

@GenerateMocks([IbUtils, AuthController])
void main() {
  final mockUtils = MockIbUtils();
  final mockAuth = MockAuthController();
  final controller = SignUpController(mockUtils, mockAuth);

  test('test empty password', () {
    controller.password.value = '';
    controller.validatePassword();
    expect('field_is_empty', equals(controller.pwdErrorTrKey.value));
    expect(false, equals(controller.isPasswordValid.value));
  });

  test('test less than 6 char password', () {
    controller.password.value = '12313';
    controller.validatePassword();
    expect('6_characters_error', equals(controller.pwdErrorTrKey.value));
    expect(false, equals(controller.isPasswordValid.value));
  });

  test('test valid password', () {
    controller.password.value = '123131';
    controller.validatePassword();
    expect('', equals(controller.pwdErrorTrKey.value));
    expect(true, equals(controller.isPasswordValid.value));
  });

  test('test empty CfPassword', () {
    controller.confirmPassword.value = '';
    controller.validateCfPassword();
    expect('field_is_empty', equals(controller.confirmPwdErrorTrKey.value));
    expect(false, equals(controller.isCfPwdValid.value));
  });

  test('test less than 6 char CfPassword', () {
    controller.confirmPassword.value = '12313';
    controller.validateCfPassword();
    expect('6_characters_error', equals(controller.confirmPwdErrorTrKey.value));
    expect(false, equals(controller.isCfPwdValid.value));
  });

  test('test CfPassword does not match', () {
    controller.confirmPassword.value = '12313112313';
    controller.password.value = '123131';
    controller.validateCfPassword();
    expect(
        'password_match_error', equals(controller.confirmPwdErrorTrKey.value));
    expect(false, equals(controller.isCfPwdValid.value));
  });

  test('test valid CfPassword', () {
    controller.password.value = '123131';
    controller.confirmPassword.value = '123131';
    controller.validateCfPassword();
    expect('', equals(controller.pwdErrorTrKey.value));
    expect(true, equals(controller.isCfPwdValid.value));
  });

  test('test not valid email', () {
    final notValidEmails = [
      '',
      '  ',
      '#@%^%#@#@#.com',
      '@domain.com',
      'Joe Smith <email@domain.com>',
      'email.domain.com',
      'email@domain@domain.com',
      '.email@domain.com',
      'email.@domain.com',
      'email..email@domain.com',
      'email@domain.com (Joe Smith)',
      'email@domain',
      'email@111.222.333.44444',
      'email@domain..com'
    ];
    for (final email in notValidEmails) {
      print(email);
      controller.email.value = email;
      controller.validateEmail();
      expect(false, equals(controller.isEmailValid.value));
    }
  });
  test('test valid email', () {
    final validEmails = [
      'email@domain.com',
      'email@subdomain.domain.com',
      'firstname+lastname@domain.com',
      '“email”@domain.com',
      '1234567890@domain.com',
      'email@domain-one.com',
      '_______@domain.com',
      'email@domain.name',
      'email@domain.co.jp',
      'firstname-lastname@domain.com',
    ];
    for (final email in validEmails) {
      print(email);
      controller.email.value = email;
      controller.validateEmail();
      expect(true, equals(controller.isEmailValid.value));
    }
  });

  test('test checkboxes', () {
    controller.isOver13.value = false;
    controller.isTermRead.value = false;
    controller.validateCheckBox();
    controller.isOver13.value = true;
    controller.validateCheckBox();
    verify(mockUtils.showDialog(argThat(isInstanceOf<IbDialog>()))).called(2);
  });

  test('test sign up', () {
    when(mockAuth.signUpViaEmail(any, any)).thenAnswer((_) async => 'Stub');
    controller.isOver13.value = true;
    controller.isTermRead.value = true;
    controller.email.value = '123@gmail.com';
    controller.password.value = '12345678';
    controller.confirmPassword.value = '12345678';
    controller.signUp();
    verify(mockUtils.hideKeyboard()).called(1);
    verify(mockAuth.signUpViaEmail(argThat(equals(controller.email.value)),
            argThat(equals(controller.password.value))))
        .called(1);
  });
}
