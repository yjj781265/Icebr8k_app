import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/create_question_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_friends_picker_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/friends_picker.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../backend/controllers/user_controllers/social_tab_controller.dart';
import '../chat_picker_page.dart';

/// p.s all changes need to be made in rxIbQuestion except the shared chats and shared friends
class ReviewQuestionPage extends StatelessWidget {
  final CreateQuestionController createQuestionController;
  final IbQuestionItemController itemController;
  final ScrollController scrollController = ScrollController();

  ReviewQuestionPage(
      {Key? key,
      required this.createQuestionController,
      required this.itemController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Your Poll'),
        actions: [
          TextButton(
            onPressed: () async {
              await createQuestionController
                  .submitQuestion(itemController.rxIbQuestion.value);
            },
            child: Text('submit'.tr,
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize)),
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => Scrollbar(
            controller: scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(
                    () => IbUtils.handleQuestionType(
                        itemController.rxIbQuestion.value,
                        itemController: itemController),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Options',
                      style: TextStyle(
                          fontSize: IbConfig.kNormalTextSize,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  ListTile(
                    tileColor: Theme.of(context).primaryColor,
                    leading: const Icon(
                      Icons.hourglass_top_outlined,
                      color: Colors.redAccent,
                    ),
                    onTap: () {
                      _timeLimitBtmSheet();
                    },
                    title: const Text('Time Limit'),
                    trailing: Obx(() {
                      if (itemController.rxIbQuestion.value.endTimeInMs == -1) {
                        return const Text('No Time Limit');
                      }
                      return IbUtils.leftTimeText(
                          itemController.rxIbQuestion.value.endTimeInMs);
                    }),
                  ),
                  Obx(
                    () => ListTile(
                      onTap: () {
                        _showPrivacyBound();
                      },
                      tileColor: Theme.of(context).primaryColor,
                      trailing: Text(_getPrivacyBondsString()),
                      title: const Text(
                        'Privacy Bonds',
                      ),
                      leading: const Icon(
                        Icons.remove_red_eye,
                        color: IbColors.primaryColor,
                      ),
                    ),
                  ),
                  Obx(
                    () => SwitchListTile.adaptive(
                      tileColor: Theme.of(context).primaryColor,
                      value: itemController.rxIbQuestion.value.isCommentEnabled,
                      onChanged: (value) {
                        itemController.rxIbQuestion.value.isCommentEnabled =
                            value;
                        itemController.rxIbQuestion.refresh();
                      },
                      title: const Text('Comment'),
                      secondary: const Icon(
                        FontAwesomeIcons.comment,
                        color: IbColors.accentColor,
                      ),
                    ),
                  ),
                  Obx(
                    () => SwitchListTile.adaptive(
                      tileColor: Theme.of(context).primaryColor,
                      value: itemController.rxIbQuestion.value.isShareable,
                      onChanged: (value) {
                        itemController.rxIbQuestion.value.isShareable = value;
                        itemController.rxIbQuestion.refresh();
                      },
                      title: const Text('Shareable'),
                      secondary: const Icon(
                        FontAwesomeIcons.share,
                        color: IbColors.lightGrey,
                      ),
                    ),
                  ),
                  Obx(() {
                    if (itemController.rxIbQuestion.value.questionType ==
                            QuestionType.multipleChoice &&
                        !itemController.rxIbQuestion.value.isQuiz) {
                      return SwitchListTile.adaptive(
                        tileColor: Theme.of(context).primaryColor,
                        value: itemController.rxIbQuestion.value.isOpenEnded,
                        onChanged: (value) {
                          itemController.rxIbQuestion.value.isOpenEnded = value;
                          itemController.rxIbQuestion.refresh();
                        },
                        title: const Text('Allow Others to Add Choices'),
                        secondary: const Icon(
                          FontAwesomeIcons.plus,
                          color: IbColors.primaryColor,
                        ),
                      );
                    }
                    return const SizedBox();
                  }),
                  if (!itemController.rxIbQuestion.value.questionType
                      .toString()
                      .contains('sc'))
                    Obx(
                      () => SwitchListTile.adaptive(
                        tileColor: Theme.of(context).primaryColor,
                        value: itemController.rxIbQuestion.value.isQuiz,
                        onChanged: (value) async {
                          itemController.rxIbQuestion.value.isQuiz = value;
                          itemController.rxIbQuestion.refresh();
                          if (value) {
                            scrollController.animateTo(0.0,
                                curve: Curves.linear,
                                duration: const Duration(
                                    milliseconds:
                                        IbConfig.kEventTriggerDelayInMillis));
                            itemController.rxIsExpanded.value = true;
                            //give time to animate
                            if (!IbLocalDataService().retrieveBoolValue(
                                StorageKey.pickAnswerForQuizShowCaseBool)) {
                              await Future.delayed(const Duration(seconds: 1))
                                  .then((value) {
                                ShowCaseWidget.of(itemController
                                        .quizShowCaseKey.currentContext!)
                                    .startShowCase(
                                        [itemController.quizShowCaseKey]);
                              });
                            }
                          } else {
                            itemController.rxIbQuestion.value.correctChoiceId =
                                '';
                          }
                        },
                        title: const Text('Quiz'),
                        secondary: const Icon(
                          FontAwesomeIcons.question,
                          color: IbColors.accentColor,
                        ),
                      ),
                    ),
                  Obx(
                    () => SwitchListTile.adaptive(
                      tileColor: Theme.of(context).primaryColor,
                      value: itemController.rxIbQuestion.value.isAnonymous,
                      onChanged: (value) {
                        itemController.rxIbQuestion.value.isAnonymous = value;
                        itemController.rxIbQuestion.refresh();
                      },
                      title: const Text('Anonymous'),
                      secondary: const Icon(
                        Icons.person,
                        color: IbColors.lightGrey,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _timeLimitBtmSheet() {
    Get.bottomSheet(
        SafeArea(
          child: IbCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: IbColors.primaryColor,
                  ),
                  title: const Text('Pick a date and time'),
                  onTap: () {
                    Get.back();
                    _showDateTimePicker();
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.loop_outlined,
                    color: IbColors.accentColor,
                  ),
                  title: const Text('No Time Limit'),
                  onTap: () {
                    itemController.rxIbQuestion.value.endTimeInMs = -1;
                    itemController.rxIbQuestion.refresh();
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
        ignoreSafeArea: false);
  }

  void _showDateTimePicker() {
    itemController.rxIbQuestion.value.endTimeInMs =
        DateTime.now().add(const Duration(minutes: 15)).millisecondsSinceEpoch;
    Get.bottomSheet(
        IbCard(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(
              () => Center(
                child: Text(
                  '${DateTime.fromMillisecondsSinceEpoch(itemController.rxIbQuestion.value.endTimeInMs).year}',
                  style: const TextStyle(fontSize: IbConfig.kPageTitleSize),
                ),
              ),
            ),
            SizedBox(
              height: 256,
              child: CupertinoDatePicker(
                maximumDate: DateTime.now().add(const Duration(days: 365)),
                maximumYear: 1,
                onDateTimeChanged: (value) async {
                  await HapticFeedback.selectionClick();
                  itemController.rxIbQuestion.value.endTimeInMs =
                      value.millisecondsSinceEpoch;
                  itemController.rxIbQuestion.refresh();
                },
                initialDateTime:
                    DateTime.now().add(const Duration(minutes: 20)),
                minimumDate: DateTime.now().add(const Duration(minutes: 15)),
                dateOrder: DatePickerDateOrder.ymd,
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: IbElevatedButton(
                  textTrKey: 'ok',
                  onPressed: () {
                    Get.back();
                  }),
            ),
            const SizedBox(
              height: 16,
            ),
          ],
        )),
        ignoreSafeArea: false);
  }

  void _showPrivacyBound() {
    final Widget dialog = IbCard(
      radius: 8,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Share with',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: IbConfig.kNormalTextSize),
              ),
            ),
            Obx(
              () => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                value: itemController.rxIbQuestion.value.isPublic,
                onChanged: (flag) {
                  final bool isPublic = flag ?? false;
                  if (isPublic) {
                    itemController.rxIbQuestion.value.isPublic = true;
                  } else {
                    itemController.rxIbQuestion.value.isPublic = false;
                  }
                  itemController.rxIbQuestion.refresh();
                },
                title: const Text(
                  'Public',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
                subtitle: const Text(
                  'Every icebr8k users(include your friends) will have access to see it',
                  style: TextStyle(
                      fontSize: IbConfig.kDescriptionTextSize,
                      color: IbColors.lightGrey),
                ),
              ),
            ),
            Obx(
              () => itemController.rxIbQuestion.value.isPublic
                  ? const SizedBox()
                  : ListTile(
                      onTap: () async {
                        final users = await Get.to(() => FriendsPicker(
                              Get.put(IbFriendsPickerController(
                                IbUtils.getCurrentUid()!,
                                allowEdit: true,
                                pickedUids: createQuestionController
                                    .pickedFriends
                                    .map((element) => element.id)
                                    .toList(),
                              )),
                              buttonTxt: 'confirm'.tr,
                            ));
                        if (users != null) {
                          createQuestionController.pickedFriends.value =
                              users as List<IbUser>;
                        }
                      },
                      title: const Text(
                        'Friends Only',
                        style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                      subtitle: Text(
                        _getFriendString(),
                        style: const TextStyle(
                            fontSize: IbConfig.kSecondaryTextSize),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                    ),
            ),
            Obx(
              () => ListTile(
                onTap: () async {
                  List<ChatTabItem>? chats = await Get.to(
                    () => ChatPickerPage(
                      pickedItems: createQuestionController.pickedChats,
                    ),
                  );

                  chats ??= <ChatTabItem>[
                    ...createQuestionController.pickedChats
                  ];
                  createQuestionController.pickedChats.value = chats;
                },
                title: const Text(
                  'Chats',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
                subtitle: Text(
                  createQuestionController.pickedChats.isEmpty
                      ? 'None'
                      : _getChatString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: IbConfig.kSecondaryTextSize,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
              ),
            ),
            Container(
                margin: const EdgeInsets.all(16),
                width: double.infinity,
                height: 40,
                child: Obx(
                  () => IbElevatedButton(
                    disabled: createQuestionController.pickedChats.isEmpty &&
                        createQuestionController.pickedFriends.isEmpty &&
                        !itemController.rxIbQuestion.value.isPublic,
                    textTrKey: 'confirm',
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ))
          ],
        ),
      ),
    );
    Get.dialog(Center(
      child: dialog,
    ));
  }

  String _getChatString() {
    final StringBuffer sb = StringBuffer();
    final int chatCount = createQuestionController.pickedChats
        .where((p0) => !p0.ibChat.isCircle)
        .length;
    final int circleCount = createQuestionController.pickedChats
        .where((p0) => p0.ibChat.isCircle)
        .length;
    if (chatCount > 0 && circleCount > 0) {
      sb.write('$chatCount Chat(s), ');
    } else if (chatCount > 0 && circleCount == 0) {
      sb.write('$chatCount Chat(s)');
    }

    if (circleCount > 0) {
      sb.write('$circleCount Circle(s)');
    }

    return sb.toString();
  }

  String _getFriendString() {
    final StringBuffer sb = StringBuffer();
    final int friendCount = createQuestionController.pickedFriends.length;
    if (friendCount == 0) {
      return 'None';
    }

    if (friendCount == 1) {
      for (final friend in createQuestionController.pickedFriends) {
        sb.write(friend.username);
      }
    }

    if (friendCount > 1 && friendCount <= 2) {
      for (final friend in createQuestionController.pickedFriends) {
        sb.write('${friend.username}, ');
      }
    }

    if (friendCount > 2) {
      int counter = 0;
      for (final friend in createQuestionController.pickedFriends) {
        if (counter == 2) {
          break;
        }
        sb.write('${friend.username}, ');
        counter++;
      }
      sb.write(
          'and ${createQuestionController.pickedFriends.length - 2} others ');
    }

    return sb.toString();
  }

  String _getPrivacyBondsString() {
    final StringBuffer sb = StringBuffer();
    final bool includeComma =
        createQuestionController.pickedFriends.isNotEmpty ||
            createQuestionController.pickedChats.isNotEmpty;
    if (itemController.rxIbQuestion.value.isPublic) {
      final str = includeComma ? 'Public, ' : 'Public';
      sb.write(str);
    }
    if (createQuestionController.pickedFriends.isNotEmpty &&
        !itemController.rxIbQuestion.value.isPublic) {
      final str = createQuestionController.pickedChats.isEmpty
          ? '${createQuestionController.pickedFriends.length} Friend(s)'
          : '${createQuestionController.pickedFriends.length} Friend(s),';
      sb.write(str);
    }

    if (createQuestionController.pickedChats.isNotEmpty) {
      final str = ' ${createQuestionController.pickedChats.length} Chats(s)';
      sb.write(str);
    }

    return sb.toString();
  }
}
