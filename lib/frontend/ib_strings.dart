import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';

class IbStrings extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          'welcome_msg': 'Welcome',
          'welcome_msg_desc': 'Please enter the details to continue with app',
          'email_address': 'Email Address',
          'email_address_hint': 'Please enter email address',
          'password': 'Password',
          'reset_pwd': 'Reset password',
          'password_hint': 'Please enter password',
          'confirm_password': 'Confirm Password',
          'confirm_password_hint': 'Please confirm password',
          'forget_pwd': "Forgot Password?",
          'sign_in_google': 'Sign in with Google',
          'or': 'OR',
          'ok': 'Okay',
          'login': 'Login',
          'new_here': 'New here? ',
          'sign_up': 'Sign up',
          'name': 'Name',
          'name_hint': 'Please enter name',
          'birthdate': 'Birthdate',
          'birthdate_hint': 'Please enter your birthdate',
          'confirm': 'Confirm',
          'cancel': 'Cancel',
          'email_not_valid': 'Email is not valid',
          'date_picker_instruction': 'Please pick your birthdate',
          'field_is_empty': 'Field is empty',
          '6_characters_error': 'At least 6 characters',
          '3_characters_error': 'At least 3 characters',
          'password_match_error': 'Password does not match',
          'age_limit_msg': 'User needs to be at least age of 13',
          'loading': 'Loading...',
          'signing_in': 'Signing in...',
          'signing_up': 'Signing up...',
          'resend_verification_email': 'Resend email',
          'verification_email_sent': 'Verification email from Icebr8k is sent.',
          'reset_email_intro':
              'Please enter the email you want to reset the password for in below',
          'reset_email_msg': "Password reset email has been sent to @email.",
          'sign_up_email_verification':
              'Sign up success! Please check your email inbox for verification from Icebr8k.',
          'sign_in_email_verification':
              'This email address is not verified, please check your inbox for verification email from Icebr8k.',
          'sign_out': "Sign out",
          'signing_out': 'Signing out...',
          'next': 'Next',
          'selfie_time': 'Time to take a selfie',
          'slogan_one': "Let's start to connect better",
          'camera': 'Camera',
          'gallery': 'Gallery',
          'username': 'Username',
          'username_hint': 'Create your unique username',
          'username_exist_error': 'Username already exists',
          'username_not_valid':
              'Username is not valid, make sure it has at least 2 characters without spacing',
          'username_empty':
              "Oops, looks like you forgot to create your username.",
          'avatar_empty':
              'Oops, looks like you forgot to pick your selfie picture.',
          'fail_try_again': 'Failed, please try again',
          'to_previous_page': 'To previous page',
          'chat': 'Chat',
          'score': 'Score',
          'question': 'Question',
          'profile': 'Profile',
          'add_choice': 'Add a choice',
          'add_endpoint': 'Add an endpoint',
          'tap_to_add': 'Tap to add up to ${IbConfig.kChoiceLimit} choices',
          'tap_to_add_sc': 'Tap to add 2 end points',
          'add': 'Add',
          'choice_limit':
              'You can only have max ${IbConfig.kChoiceLimit} choices per question.',
          'choice_limit_sc':
              'You can only have max ${IbConfig.kScChoiceLimit} endpoints per scale question.',
          'sc_question_not_valid': 'You need 2 endpoints for a scale question',
          'mc_question_not_valid':
              'You need at least 2 choices for a multiple choice question',
          'description_option': 'Description(optional)',
          'create_question': 'Create a question',
          'mc': 'Multiple Choice',
          'sc': 'Scale',
          'question_empty': 'Question field is empty',
          'vote': 'Vote',
          'voting': 'Voting...',
          'voted': 'Voted',
          'submit': 'Submit',
          'submitting': 'Submitting...',
          'submitted': 'Submitted',
          'search': 'Search',
          'user_not_found': 'User not found',
          'username_search_hint': 'Type Icebr8k username here',
          'friend_request_dialog_title': 'Send @username a friend request?',
          'friend_request_msg_hint': 'Leave a personal message(optional)',
          'send_friend_request': 'Send friend request',
          'send_friend_request_success': 'Friend request sent',
          'score_page_tab_1_title': 'Friends',
          'score_page_tab_2_title': 'Friend Requests',
          'friend_request_accepted': 'Friend request accepted',
          'friend_request_declined': 'Friend request declined',
          'show_result': 'Show result'
        }
      };
}
