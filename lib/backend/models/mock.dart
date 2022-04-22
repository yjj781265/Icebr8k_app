import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class Mock {
  static String kImageUrl1 =
      'https://firebasestorage.googleapis.com/v0/b/icebr8k-flutter.appspot.com/o/images%2F0247a830-ff5c-4a38-97fc-a66773522c8d.png?alt=media&token=f67fbeb8-c40b-401d-a09f-b086514c32da';
  static String kImageUrl2 =
      'https://firebasestorage.googleapis.com/v0/b/icebr8k-flutter.appspot.com/o/images%2F1462994c-a3ed-44ac-bdae-ce206d1f99df.png?alt=media&token=c8a7d78c-6eed-4921-942b-8d5c03ac7d44';

  static String kImageUrl3 =
      'https://media1.giphy.com/media/RtdRhc7TxBxB0YAsK6/giphy.gif?cid=ecf05e47fmai3bmyisbu246kh73wb5vx746sue2f0cna19ff&rid=giphy.gif&ct=g';

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
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Nature',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Sports',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Seasons',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Movies',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Music',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Games',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Novels',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Cartoons',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Pop',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Picture',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Riddle',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Pets',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Colors',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Dance',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Food',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'News',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Geography',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Funny',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Family',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Animal',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Art',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Bird',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Biology',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Geek',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Ocean',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Sports',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Super Bowl',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Video Game',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Television',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'World',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Science',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Religion',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Christian',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Business',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'General',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Harry Potter',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'Dogs',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
    IbTag(
        text: 'History',
        creatorId: IbUtils.getCurrentFbUser()!.uid,
        questionCount: 0),
  ];
}
