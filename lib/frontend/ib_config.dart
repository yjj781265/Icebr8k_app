import 'package:icebr8k/backend/db_config.dart';

class IbConfig {
  static const double kLoadingIndicatorSize = 40;
  static const double kAppLogoSize = 96;
  static const double kCardCornerRadius = 16;
  static const double kScrollbarCornerRadius = 16;
  static const double kTextBoxCornerRadius = 16;
  static const double kButtonCornerRadius = 16;
  static const int kFriendsLimit = 200;
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
  static const int kQuestionTitleMaxLength = 100; //characters
  static const int kFriendRequestMsgMaxLength = 100; //characters
  static const int kQuestionDescMaxLength = 500; //characters
  static const int kBioMaxLength = 2000; //characters
  static const int kBioMaxLines = 100; //c
  static const int kAnswerMaxLength = 30; // characters
  static const int kScAnswerMaxLength = 20; // characters
  static const double kInitChatMessagesLoadSize = 16;
  static const double kChatMessagesTextSize = 18;
  static const int kImageQuality = 70;
  static const double kMcTxtItemSize = 48;
  static const double kMcPicItemSize = 88;
  static const int kMaxTag = 8;
  static const double kMcPicSize = 72;
  static const double kPicHeight = 88;
  static const double kScItemHeight = 48;
  static const double kMcItemCornerRadius = 8;
  static const int kCommentMaxLen = 2000;
  static const String kDefaultCoverPhotoUrl =
      'https://firebasestorage.googleapis.com/v0/b/icebr8k-flutter.appspot.com/o/images%2Fheader_img.jpg?alt=media&token=070dea5e-269a-467c-acb8-35ba7a5fde39';
  static const List<String> kFirst8QuestionIds = [
    "0bfe7dcd-49f2-419f-a3a1-66f16000cb89",
    '32351860-a06c-4d11-89e3-b05328c7894c',
    '3edff96e-81c3-4ee3-a6ad-6090781a99c2',
    '70f7b948-98af-42c6-b361-a0606a47e304',
    '7db72ff2-2fc8-455c-b49c-a85e2d0c8f62',
    'a30b0c6f-b05f-4a7f-8620-bd2274be4891',
    'b8b0223b-2b7b-460e-9267-4be1395d4092',
    'c7dc24b9-9f5e-4e9d-8fc6-aab4dd45e072,'
  ];
  static const String kVersion = '0.1.1${DbConfig.dbSuffix}';

  IbConfig._();
}
