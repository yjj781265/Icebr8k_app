import 'package:icebr8k/backend/db_config.dart';

class IbConfig {
  static const double kLoadingIndicatorSize = 40;
  static const double kAppLogoSize = 96;
  static const double kCardCornerRadius = 16;
  static const double kScrollbarCornerRadius = 16;
  static const double kTextBoxCornerRadius = 16;
  static const double kButtonCornerRadius = 16;
  static const double kSloganSize = 32;
  static const double kPageTitleSize = 20;
  static const double kSecondaryTextSize = 14;
  static const double kDescriptionTextSize = 12;
  static const double kNormalTextSize = 16;
  static const int kEventTriggerDelayInMillis = 300;
  static const int kUpdateResultMinCadenceInMillis = 8000;
  static const int kAgeLimitInDays = 4745;
  static const int kPicChoiceLimit = 9;
  static const int kScChoiceLimit = 2;
  static const int kPasswordMinLength = 6;
  static const int kUsernameMinLength = 3;
  static const int kUsernameMaxLength = 20;
  static const int kQuestionTitleMaxLength = 100; //characters
  static const int kFriendRequestMsgMaxLength = 100; //characters
  static const int kQuestionDescMaxLength = 100; //characters
  static const int kBioMaxLength = 300; //characters
  static const int kAnswerMaxLength = 30; // characters
  static const int kScAnswerMaxLength = 20; // characters
  static const double kInitChatMessagesLoadSize = 16;
  static const double kChatMessagesTextSize = 18;
  static const int kImageQuality = 70;
  static const double kMcTxtItemHeight = 48;
  static const double kMcPicItemHeight = 88;
  static const double kMcPicHeight = 72;
  static const double kPicHeight = 88;

  static const double kMcItemCornerRadius = 8;
  static const String kVersion = '0.1.1${DbConfig.dbSuffix}';

  IbConfig._();
}
