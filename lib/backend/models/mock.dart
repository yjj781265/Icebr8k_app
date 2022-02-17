import 'package:icebr8k/backend/models/ib_answer.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class Mock {
  static String kImageUrl1 =
      'https://firebasestorage.googleapis.com/v0/b/icebr8k-flutter.appspot.com/o/images%2F0247a830-ff5c-4a38-97fc-a66773522c8d.png?alt=media&token=f67fbeb8-c40b-401d-a09f-b086514c32da';
  static String kImageUrl2 =
      'https://firebasestorage.googleapis.com/v0/b/icebr8k-flutter.appspot.com/o/images%2F1462994c-a3ed-44ac-bdae-ce206d1f99df.png?alt=media&token=c8a7d78c-6eed-4921-942b-8d5c03ac7d44';

  static String kImageUrl3 =
      'https://media1.giphy.com/media/RtdRhc7TxBxB0YAsK6/giphy.gif?cid=ecf05e47fmai3bmyisbu246kh73wb5vx746sue2f0cna19ff&rid=giphy.gif&ct=g';

  static List<IbAnswer> kCommonIbAnswers = [
    IbAnswer(
        choiceId: 'c3f19af1-d065-4652-8c75-1af745437e63',
        answeredTimeInMs: 0,
        askedTimeInMs: 123,
        questionId: 'f52b0b63-034c-48af-bc9a-bfb6ac535061',
        questionType: 'mc',
        uid: 'rHxvU2vekdMpgkDlk1ekOACzmlG3'),
    IbAnswer(
        choiceId: 'c3f19af1-d065-4652-8c75-1af745437e63',
        answeredTimeInMs: 0,
        askedTimeInMs: 123,
        questionId: 'f52b0b63-034c-48af-bc9a-bfb6ac535061',
        questionType: 'mc',
        uid: 'HNwANcBUTpY6L2L3AZYU6x3OIBG3')
  ];

  static List<String> gifUrls = [
    'https://media.tenor.com/images/0299b55a1c548d4af747a30af607f3a1/tenor.gif',
    'https://media.tenor.com/images/f76d1ef44fc71ace3d8d0bc2f185abbb/tenor.gif',
    'https://media.tenor.com/images/fbeb18f6d22b7201118db0b414511ec2/tenor.gif',
    'https://media.tenor.com/images/a24f005e1420efa65c8edea4ac02222b/tenor.gif',
    'https://media.tenor.com/images/f76d1ef44fc71ace3d8d0bc2f185abbb/tenor.gif',
    'https://media.tenor.com/images/fbeb18f6d22b7201118db0b414511ec2/tenor.gif',
    'https://media.tenor.com/images/a24f005e1420efa65c8edea4ac02222b/tenor.gif',
    'https://media.tenor.com/images/f76d1ef44fc71ace3d8d0bc2f185abbb/tenor.gif',
    'https://media.tenor.com/images/fbeb18f6d22b7201118db0b414511ec2/tenor.gif',
    'https://media.tenor.com/images/a24f005e1420efa65c8edea4ac02222b/tenor.gif',
    'https://media.tenor.com/images/f76d1ef44fc71ace3d8d0bc2f185abbb/tenor.gif',
    'https://media.tenor.com/images/fbeb18f6d22b7201118db0b414511ec2/tenor.gif',
    'https://media.tenor.com/images/a24f005e1420efa65c8edea4ac02222b/tenor.gif',
  ];

  static List<IbTag> tags = [
    IbTag(
        text: 'Math',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Nature',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Sports',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Seasons',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Movies',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Movies',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Music',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Games',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Novels',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Cartoons',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Pop',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Picture',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Riddle',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Pets',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Colors',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Dance',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Food',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'News',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Geography',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Funny',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Family',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Animal',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Art',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Bird',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Biology',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Geek',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Ocean',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Sports',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Super Bowl',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Video Game',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Television',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'World',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Science',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Religion',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Christian',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Business',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'General',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Harry Potter',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Dogs',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'History',
        id: IbUtils.getUniqueId(),
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
  ];
}
