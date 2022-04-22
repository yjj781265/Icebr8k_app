import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_tab_controller.dart';
import 'package:icebr8k/backend/managers/ib_show_case_manager.dart';
import 'package:icebr8k/backend/models/ib_chat_models/ib_message.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/services/user_services/ib_chat_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_tag_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/create_question_pages/circle_picker_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_mc_question_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_sc_question_card.dart';
import 'package:showcaseview/showcaseview.dart';

import '../../../backend/controllers/user_controllers/ib_question_item_controller.dart';

class ReviewQuestionPage extends StatelessWidget {
  final IbQuestionItemController itemController;
  const ReviewQuestionPage({Key? key, required this.itemController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review your question'),
        actions: [
          TextButton(
            onPressed: () async {
              await submitQuestion(itemController.rxIbQuestion.value);
            },
            child: Text('submit'.tr,
                style: const TextStyle(fontSize: IbConfig.kNormalTextSize)),
          ),
        ],
      ),
      body: SafeArea(
        child: ShowCaseWidget(
          onFinish: () {
            IbLocalDataService().updateBoolValue(
                key: StorageKey.pickAnswerForQuizBool, value: true);
          },
          builder: Builder(
            builder: (context) => Scrollbar(
              isAlwaysShown: true,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _handleQuestionType(),
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
                        if (itemController.rxIbQuestion.value.endTimeInMs ==
                            -1) {
                          return const Text('No Time Limit');
                        }
                        return IbUtils.leftTimeText(
                            itemController.rxIbQuestion.value.endTimeInMs);
                      }),
                    ),
                    Obx(
                      () => SwitchListTile.adaptive(
                        tileColor: Theme.of(context).primaryColor,
                        value:
                            itemController.rxIbQuestion.value.isCommentEnabled,
                        onChanged: (value) {
                          itemController.rxIbQuestion.value.isCommentEnabled =
                              value;
                          itemController.rxIbQuestion.refresh();
                        },
                        title: const Text('Comment'),
                        secondary: const Icon(
                          FontAwesomeIcons.comment,
                          color: IbColors.primaryColor,
                        ),
                      ),
                    ),
                    if (!itemController.rxIbQuestion.value.questionType
                        .contains('sc'))
                      Obx(
                        () => SwitchListTile.adaptive(
                          tileColor: Theme.of(context).primaryColor,
                          value: itemController.rxIbQuestion.value.isQuiz,
                          onChanged: (value) {
                            if (value) {
                              itemController.rxIsExpanded.value = true;
                              ShowCaseWidget.of(context)!.startShowCase(
                                  [IbShowCaseManager.kPickAnswerForQuizKey]);
                            } else {
                              itemController
                                  .rxIbQuestion.value.correctChoiceId = '';
                            }
                            itemController.rxIbQuestion.value.isQuiz = value;
                            itemController.rxIbQuestion.refresh();
                          },
                          title: const Text('Quiz'),
                          secondary: const Icon(
                            FontAwesomeIcons.question,
                            color: IbColors.accentColor,
                          ),
                        ),
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
      ),
    );
  }

  Widget _handleQuestionType() {
    if (itemController.rxIbQuestion.value.questionType ==
            IbQuestion.kMultipleChoice ||
        itemController.rxIbQuestion.value.questionType ==
            IbQuestion.kMultipleChoicePic) {
      return IbMcQuestionCard(itemController);
    }
    return IbScQuestionCard(
      itemController,
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
                  final list = <String>[];
                  if (isPublic) {
                    itemController.rxIbQuestion.value.isPublic = true;
                    list.addAll(IbUtils.getCurrentIbUserUnblockedFriendsId());
                  } else {
                    itemController.rxIbQuestion.value.isPublic = false;
                  }
                  itemController.rxIbQuestion.value.sharedFriendUids = list;
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
              () => CheckboxListTile(
                controlAffinity: ListTileControlAffinity.trailing,
                value: !itemController.rxIbQuestion.value.isPublic,
                onChanged: (flag) {
                  final bool isFriendsOnly = flag ?? false;
                  final list = <String>[];
                  if (isFriendsOnly) {
                    itemController.rxIbQuestion.value.isPublic = false;
                    list.addAll(IbUtils.getCurrentIbUserUnblockedFriendsId());
                  } else {
                    itemController.rxIbQuestion.value.isPublic = true;
                  }

                  itemController.rxIbQuestion.value.sharedFriendUids = list;
                  itemController.rxIbQuestion.refresh();
                },
                title: const Text(
                  'Friends Only',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
                subtitle: const Text(
                  'Only your awesome friends will have access to see it',
                  style: TextStyle(
                      fontSize: IbConfig.kDescriptionTextSize,
                      color: IbColors.lightGrey),
                ),
              ),
            ),
            Obx(
              () => ListTile(
                onTap: () async {
                  List<ChatTabItem>? circles = await Get.to(
                      () => CirclePickerPage(
                            pickedItems: itemController.sharedCircles,
                          ),
                      fullscreenDialog: true);

                  circles ??= <ChatTabItem>[...itemController.sharedCircles];
                  itemController.sharedCircles.value = circles;
                  print('Shared Circle ${itemController.sharedCircles}');
                },
                title: const Text(
                  'Circles',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ),
                subtitle: Text(
                  itemController.sharedCircles.isEmpty
                      ? 'None'
                      : _getCircleString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: IbConfig.kDescriptionTextSize,
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
                    disabled: itemController.sharedCircles.isEmpty &&
                        itemController
                            .rxIbQuestion.value.sharedFriendUids.isEmpty,
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

  String _getCircleString() {
    String str = '';
    for (int i = 0; i < itemController.sharedCircles.length; i++) {
      if (i == 2) {
        break;
      }
      if (i == itemController.sharedCircles.length - 1) {
        str = '$str${itemController.sharedCircles[i].title}';
        continue;
      }
      str = '$str${itemController.sharedCircles[i].title}, ';
    }
    if (itemController.sharedCircles.length > 2) {
      str = '$str and ${itemController.sharedCircles.length - 2} others';
    }

    return str;
  }

  String _getPrivacyBondsString() {
    String str = '';
    final bool includeComma = itemController.sharedCircles.isNotEmpty;
    if (itemController.rxIbQuestion.value.isPublic) {
      str = includeComma ? 'Public,' : 'Public';
    }
    if (!itemController.rxIbQuestion.value.isPublic) {
      str = includeComma ? 'Friends Only,' : 'Friends Only';
    }
    if (itemController.sharedCircles.isNotEmpty) {
      str = '$str ${itemController.sharedCircles.length} Circle(s)';
    }

    return str;
  }

  Future<void> submitQuestion(IbQuestion ibQuestion) async {
    if (ibQuestion.id.isEmpty ||
        ibQuestion.tags.isEmpty ||
        ibQuestion.question.isEmpty ||
        ibQuestion.choices.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle:
            'Question is not valid, make sure all required field are filled',
        showNegativeBtn: false,
      ));
      return;
    }

    if (ibQuestion.isQuiz && ibQuestion.correctChoiceId.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: 'Quiz question needs to have a correct choice picked',
        showNegativeBtn: false,
      ));
      return;
    }

    if (itemController.sharedCircles.isEmpty &&
        ibQuestion.sharedFriendUids.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: 'Privacy Bounds are empty',
        showNegativeBtn: false,
      ));
      return;
    }

    Get.dialog(const IbLoadingDialog(messageTrKey: 'Uploading...'),
        barrierDismissible: false);

    /// upload all url in choices
    for (final choice in ibQuestion.choices) {
      if (choice.url == null || choice.url!.contains('http')) {
        continue;
      }

      final String? url = await IbStorageService()
          .uploadAndRetrieveImgUrl(filePath: choice.url!);
      if (url == null) {
        IbUtils.showSimpleSnackBar(
            msg: 'Failed to upload images...',
            backgroundColor: IbColors.errorRed);
        break;
      } else {
        choice.url = url;
      }
    }

    /// upload all url in medias
    for (final media in ibQuestion.medias) {
      if (media.url.contains('http')) {
        continue;
      }

      final String? url = await IbStorageService().uploadAndRetrieveImgUrl(
        filePath: media.url,
      );
      if (url == null) {
        IbUtils.showSimpleSnackBar(
            msg: 'Failed to upload images...',
            backgroundColor: IbColors.errorRed);
        break;
      } else {
        media.url = url;
      }
    }

    /// upload all the string in tagIds
    for (final String text in ibQuestion.tags) {
      await IbTagDbService().uploadTag(text);
    }

    /// add IbMessage to selected circles
    for (final item in itemController.sharedCircles) {
      await IbChatDbService().uploadMessage(IbMessage(
          messageId: IbUtils.getUniqueId(),
          content: ibQuestion.id,
          readUids: [IbUtils.getCurrentUid()!],
          senderUid: IbUtils.getCurrentUid()!,
          messageType: IbMessage.kMessageTypePoll,
          chatRoomId: item.ibChat.chatId));
    }

    await IbQuestionDbService().uploadQuestion(ibQuestion);
    Get.back(closeOverlays: true);
    Get.back(closeOverlays: true);
    IbUtils.showSimpleSnackBar(
        msg: 'Question submitted successfully',
        backgroundColor: IbColors.accentColor);
  }
}
