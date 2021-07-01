import 'package:get/get.dart';

class IbStrings extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'welcome_msg': 'Welcome',
          'welcome_msg_desc': 'Please enter the details to continue with app',
          'email_address': 'Email Address',
          'email_address_hint': 'Please enter email address',
          'password': 'Password',
          'password_hint': 'Please enter password',
          'confirm_password': 'Confirm Password',
          'confirm_password_hint': 'Please confirm password',
          'forget_pwd': "Forgot Password?",
          'sign_in_google': 'Sign in with Google',
          'or': 'OR',
          'login': 'Login',
          'new_here': 'New here? ',
          'sign_up': 'Sign up',
          'name': 'Name',
          'name_hint': 'Please enter name',
          'birthdate': 'Birthdate',
          'birthdate_hint': 'Please enter your birthdate',
          'confirm': 'Confirm',
          'cancel': 'Cancel',
          'email_not_valid': 'email is not valid',
          'birthdate_instruction': 'Please pick a date',
          'field_is_empty': 'field is empty',
          '8_characters_error': 'at least 8 characters',
          'password_match_error': 'password does not match',
          'age_limit_msg': 'user needs to be at least age of 13',
        }
      };
}
