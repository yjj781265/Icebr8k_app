import 'package:flutter_test/flutter_test.dart';
import 'package:icebr8k/backend/controllers/user_controllers/auth_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/sign_in_controller.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_up_controller_test.mocks.dart';

@GenerateMocks([IbUtils, AuthController])
void main() {
  final mockUtils = MockIbUtils();
  final mockAuth = MockAuthController();
  final controller =
      SignInController(authController: mockAuth, utils: mockUtils);

  test('test empty password', () {
    controller.password.value = '';
    controller.validatePassword();
    expect('field_is_empty', equals(controller.passwordErrorTrKey.value));
    expect(false, equals(controller.isPasswordValid.value));
  });

  test('test less than 6 char password', () {
    controller.password.value = '12313';
    controller.validatePassword();
    expect('6_characters_error', equals(controller.passwordErrorTrKey.value));
    expect(false, equals(controller.isPasswordValid.value));
  });

  test('test valid password', () {
    controller.password.value = '123131';
    controller.validatePassword();
    expect('', equals(controller.passwordErrorTrKey.value));
    expect(true, equals(controller.isPasswordValid.value));
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

  test('sign in via email', () {
    when(mockAuth.signInViaEmail(
            email: anyNamed('email'), password: anyNamed('password')))
        .thenAnswer((_) async => 'Stub');
    controller.email.value = 'email@domain.com';
    controller.password.value = '12344556';
    controller.signInViaEmail();
    verify(mockUtils.hideKeyboard()).called(1);
    verify(mockAuth.signInViaEmail(
            email: argThat(equals(controller.email.value), named: 'email'),
            password:
                argThat(equals(controller.password.value), named: 'password'),
            rememberEmail: argThat(equals(controller.rememberLoginEmail.value),
                named: 'rememberEmail')))
        .called(1);
  });
}
