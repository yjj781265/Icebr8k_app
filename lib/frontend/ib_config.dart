import 'package:icebr8k/backend/db_config.dart';

class IbConfig {
  static const double kLoadingIndicatorSize = 40;
  static const double kAppLogoSize = 96;
  static const double kCardCornerRadius = 16;
  static const int kPerPage = 16;
  static const double kScrollbarCornerRadius = 16;
  static const double kTextBoxCornerRadius = 16;
  static const double kButtonCornerRadius = 16;
  static const int kFriendsLimit = 150;
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
  static const int kMaxImagesCount = 4;
  static const int kPasswordMinLength = 6;
  static const int kUsernameMinLength = 3;
  static const int kUsernameMaxLength = 20;
  static const int kQuestionTitleMaxLength = 150; //characters
  static const int kFriendRequestMsgMaxLength = 100; //characters
  static const int kQuestionDescMaxLength = 500; //characters
  static const int kBioMaxLength = 2000; //characters
  static const int kBioMaxLines = 100; //c
  static const int kAnswerMaxLength = 40; // characters
  static const double kInitChatMessagesLoadSize = 16;
  static const double kChatMessagesTextSize = 18;
  static const int kImageQuality = 70;
  static const double kMcTxtItemSize = 48;
  static const double kMcPicItemSize = 88;
  static const int kMaxTag = 8;
  static const double kMaxRangeInMi = 1000.0;
  static const int kIbCardMaxLine = 6;
  static const int kMaxEmoPic = 8;
  static const double kMcPicSize = 72;
  static const double kPicHeight = 88;
  static const double kScItemHeight = 48;
  static const double kMcItemCornerRadius = 8;
  static const int kCommentMaxLen = 888;
  static const int kCircleMaxMembers = 88;
  static const String kDefaultCoverPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/icebr8k-flutter.appspot.com/o/images%2Fheader_img.jpg?alt=media&token=070dea5e-269a-467c-acb8-35ba7a5fde39';
  static const String kVersion = '0.1.1${DbConfig.dbSuffix}';

  IbConfig._();
}
