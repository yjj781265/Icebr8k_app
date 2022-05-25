import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_info_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/notifications_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/circle_info.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/question_pages/question_main_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';

class AlertTab extends StatelessWidget {
  final NotificationController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Obx(() => DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text('Alert'),
              ),
              bottom: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Obx(() {
                    final int count = _controller.items
                        .where((p0) => !p0.notification.isRead)
                        .length;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.notifications),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text('Notification(s)'),
                          const SizedBox(
                            width: 4,
                          ),
                          if (count != 0)
                            CircleAvatar(
                              backgroundColor: IbColors.errorRed,
                              radius: 10,
                              child: Text(
                                count >= 99 ? '99+' : count.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                  Obx(() {
                    final int count = _controller.requests
                        .where((p0) => !p0.notification.isRead)
                        .length;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.group_add),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text('Request(s)'),
                          const SizedBox(
                            width: 4,
                          ),
                          if (count != 0)
                            CircleAvatar(
                              backgroundColor: IbColors.errorRed,
                              radius: 10,
                              child: Text(
                                count >= 99 ? '99+' : count.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              actions: [
                if (_controller.items.isNotEmpty)
                  TextButton(
                      onPressed: () async {
                        await _controller.clearAllNotifications();
                      },
                      child: const Text('Clear All'))
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: TabBarView(
                children: [
                  _itemsTab(),
                  _requestsTab(),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _itemsTab() {
    return SafeArea(
      child: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }
        if (_controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset('assets/images/monkey_zen.json')),
                const Text(
                  'No notifications at this time',
                  style: TextStyle(
                    color: IbColors.lightGrey,
                    fontSize: IbConfig.kNormalTextSize,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemBuilder: (context, index) {
            final NotificationItem item = _controller.items[index];
            return Dismissible(
                direction: DismissDirection.endToStart,
                key: ValueKey(item.notification.id),
                onDismissed: (direction) async {
                  await IbUserDbService().removeNotification(item.notification);
                },
                background: Container(
                  color: IbColors.errorRed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        Text(
                          'DELETE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                child: _handleNotificationType(item, context));
          },
          itemCount: _controller.items.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              height: 1,
            );
          },
        );
      }),
    );
  }

  Widget _requestsTab() {
    return SafeArea(
      child: Obx(() {
        if (_controller.isLoading.value) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }
        if (_controller.requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                    width: 200,
                    height: 200,
                    child: Lottie.asset('assets/images/monkey_zen.json')),
                const Text(
                  'No requests at this time',
                  style: TextStyle(
                    color: IbColors.lightGrey,
                    fontSize: IbConfig.kNormalTextSize,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          itemBuilder: (context, index) {
            final NotificationItem item = _controller.requests[index];
            return Dismissible(
                direction: DismissDirection.endToStart,
                key: ValueKey(item.notification.id),
                onDismissed: (direction) async {
                  await IbUserDbService().removeNotification(item.notification);
                },
                background: Container(
                  color: IbColors.errorRed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: const [
                        Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                        Text(
                          'DELETE',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                child: _handleNotificationType(item, context));
          },
          itemCount: _controller.requests.length,
          separatorBuilder: (BuildContext context, int index) {
            return const Divider(
              height: 1,
            );
          },
        );
      }),
    );
  }

  Widget _handleNotificationType(NotificationItem item, BuildContext context) {
    if (item.notification.type == IbNotification.kFriendRequest) {
      return IbCard(
        radius: 0,
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IbUserAvatar(
                    avatarUrl: item.avatarUrl,
                    uid: item.notification.senderId,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item.senderUser.username,
                              style: const TextStyle(
                                  fontSize: IbConfig.kNormalTextSize,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                  IbUtils.getAgoDateTimeString(
                                    DateTime.fromMillisecondsSinceEpoch((item
                                            .notification
                                            .timestamp as Timestamp)
                                        .millisecondsSinceEpoch),
                                  ),
                                  style: const TextStyle(
                                      fontSize: IbConfig.kDescriptionTextSize,
                                      color: IbColors.lightGrey)),
                            ),
                          ],
                        ),
                        Text(
                          'sent_you_a_friend_request'.tr,
                          style: const TextStyle(color: IbColors.lightGrey),
                        ),
                        if (item.notification.body.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(item.notification.body),
                          ),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  Expanded(
                      child: IbElevatedButton(
                    textTrKey: 'decline',
                    onPressed: () async {
                      await _controller.declineFr(item.notification);
                    },
                    color: IbColors.errorRed,
                  )),
                  Expanded(
                    child: IbElevatedButton(
                        textTrKey: 'accept',
                        onPressed: () async {
                          await _controller.acceptFr(item.notification);
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }
    if (item.notification.type == IbNotification.kFriendAccepted) {
      return IbCard(
        radius: 0,
        elevation: 0,
        margin: EdgeInsets.zero,
        color: item.notification.isRead ? Theme.of(context).primaryColor : null,
        child: ListTile(
          onTap: () async {
            if (!item.notification.isRead) {
              item.notification.isRead = true;
              await IbUserDbService().sendAlertNotification(item.notification);
            }
            Get.to(() => ProfilePage(
                  Get.put(ProfileController(item.senderUser.id),
                      tag: item.senderUser.id),
                ));
          },
          leading: IbUserAvatar(
              avatarUrl: item.senderUser.avatarUrl, uid: item.senderUser.id),
          title: Text(item.senderUser.username,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: IbConfig.kNormalTextSize)),
          subtitle: Text('accept_your_friend_request'.tr),
          trailing: const Icon(
            Icons.person_add_alt_1,
            color: IbColors.accentColor,
          ),
        ),
      );
    }
    if (item.notification.type == IbNotification.kCircleInvite &&
        item.ibChat != null) {
      return IbCard(
        radius: 0,
        margin: EdgeInsets.zero,
        color: item.notification.isRead ? Theme.of(context).primaryColor : null,
        child: InkWell(
          onTap: () async {
            if (!item.notification.isRead) {
              item.notification.isRead = true;
              await IbUserDbService().sendAlertNotification(item.notification);
            }
            if (item.ibChat == null) {
              return;
            }
            Get.to(
                () => CircleInfo(Get.put(CircleInfoController(item.ibChat!.obs),
                    tag: IbUtils.getUniqueId())),
                transition: Transition.downToUp,
                fullscreenDialog: true);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    if (item.avatarUrl.isNotEmpty)
                      Expanded(
                        child: IbUserAvatar(
                          radius: 21,
                          avatarUrl: item.avatarUrl,
                          uid: item.notification.senderId,
                        ),
                      ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text.rich(
                          TextSpan(text: 'Circle invite from ', children: [
                            TextSpan(
                                text: item.senderUser.username,
                                style: TextStyle(
                                    fontSize: IbConfig.kNormalTextSize,
                                    fontWeight: item.notification.isRead
                                        ? FontWeight.normal
                                        : FontWeight.bold))
                          ]),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: IbConfig.kNormalTextSize,
                          ),
                        ),
                      ),
                    ),
                    if (item.notification.timestamp != null)
                      Expanded(
                        flex: 2,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            IbUtils.getAgoDateTimeString(
                                DateTime.fromMillisecondsSinceEpoch(
                                    (item.notification.timestamp as Timestamp)
                                        .millisecondsSinceEpoch)),
                            style: const TextStyle(
                                fontSize: IbConfig.kDescriptionTextSize,
                                color: IbColors.lightGrey),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.ibChat!.photoUrl.isEmpty)
                            CircleAvatar(
                              backgroundColor: IbColors.lightGrey,
                              radius: 16,
                              child: Text(
                                item.ibChat!.name[0],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor,
                                    fontSize: IbConfig.kSecondaryTextSize,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          else
                            IbUserAvatar(
                              avatarUrl: item.ibChat!.photoUrl,
                              radius: 16,
                            ),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            flex: 8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.ibChat!.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context).indicatorColor,
                                        fontSize: IbConfig.kSecondaryTextSize,
                                        fontWeight: item.notification.isRead
                                            ? FontWeight.normal
                                            : FontWeight.bold)),
                                Text('${item.ibChat!.memberCount} member(s)',
                                    style: const TextStyle(
                                        color: IbColors.lightGrey,
                                        fontSize: IbConfig.kDescriptionTextSize,
                                        fontWeight: FontWeight.normal))
                              ],
                            ),
                          ),
                          const Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Icon(Icons.arrow_forward_ios_rounded),
                            ),
                          )
                        ],
                      ),
                      if (item.ibChat!.description.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            item.ibChat!.description,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 3,
                          ),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }

    if (item.notification.type == IbNotification.kCircleRequest &&
        item.ibChat != null) {
      return IbCard(
        radius: 0,
        margin: EdgeInsets.zero,
        color: item.notification.isRead ? Theme.of(context).primaryColor : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  if (item.avatarUrl.isNotEmpty)
                    Expanded(
                      child: IbUserAvatar(
                        radius: 21,
                        avatarUrl: item.avatarUrl,
                        uid: item.notification.senderId,
                      ),
                    ),
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text.rich(
                        TextSpan(
                            text: item.senderUser.username,
                            children: const [
                              TextSpan(
                                  text: ' requested to join a circle',
                                  style: TextStyle(
                                      fontSize: IbConfig.kNormalTextSize,
                                      fontWeight: FontWeight.normal))
                            ]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: IbConfig.kNormalTextSize,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (item.notification.timestamp != null)
                    Expanded(
                      flex: 2,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          IbUtils.getAgoDateTimeString(
                              DateTime.fromMillisecondsSinceEpoch(
                                  (item.notification.timestamp as Timestamp)
                                      .millisecondsSinceEpoch)),
                          style: const TextStyle(
                              fontSize: IbConfig.kDescriptionTextSize,
                              color: IbColors.lightGrey),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.ibChat!.photoUrl.isEmpty)
                          CircleAvatar(
                            backgroundColor: IbColors.lightGrey,
                            radius: 16,
                            child: Text(
                              item.ibChat!.name[0],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).indicatorColor,
                                  fontSize: IbConfig.kSecondaryTextSize,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        else
                          IbUserAvatar(
                            avatarUrl: item.ibChat!.photoUrl,
                            radius: 16,
                          ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          flex: 8,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.ibChat!.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: Theme.of(context).indicatorColor,
                                      fontSize: IbConfig.kSecondaryTextSize,
                                      fontWeight: item.notification.isRead
                                          ? FontWeight.normal
                                          : FontWeight.bold)),
                              Text('${item.ibChat!.memberCount} member(s)',
                                  style: const TextStyle(
                                      color: IbColors.lightGrey,
                                      fontSize: IbConfig.kDescriptionTextSize,
                                      fontWeight: FontWeight.normal))
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (item.notification.body.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          item.notification.body,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 5,
                        ),
                      ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: IbElevatedButton(
                    textTrKey: 'decline',
                    onPressed: () async {
                      await _controller.declineFr(item.notification);
                    },
                    color: IbColors.errorRed,
                  )),
                  Expanded(
                    child: IbElevatedButton(
                        textTrKey: 'accept',
                        onPressed: () async {
                          await _controller.joinCircle(item);
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    if (item.notification.type == IbNotification.kPollComment &&
        item.ibQuestion != null &&
        item.ibComment != null) {
      return IbCard(
        radius: 0,
        elevation: 0,
        margin: EdgeInsets.zero,
        color: item.notification.isRead ? Theme.of(context).primaryColor : null,
        child: ListTile(
          onTap: () async {
            if (!item.notification.isRead) {
              item.notification.isRead = true;
              await IbUserDbService().sendAlertNotification(item.notification);
            }
            Get.to(() => QuestionMainPage(
                  Get.put(
                      IbQuestionItemController(
                          rxIsSample: false.obs,
                          rxIbQuestion: item.ibQuestion!.obs,
                          rxIsExpanded: true.obs),
                      tag: item.ibQuestion!.id),
                  toPage: ToPage.comment,
                ));
          },
          leading: IbUserAvatar(
            radius: 21,
            avatarUrl: item.avatarUrl,
          ),
          title: Text.rich(
            TextSpan(text: item.senderUser.username, children: const [
              TextSpan(
                  text: ' commented on your poll:',
                  style: TextStyle(fontWeight: FontWeight.normal))
            ]),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(item.ibComment!.content),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  IbUtils.getAgoDateTimeString(
                      DateTime.fromMillisecondsSinceEpoch(
                          (item.notification.timestamp as Timestamp)
                              .millisecondsSinceEpoch)),
                  style: const TextStyle(
                      fontSize: IbConfig.kDescriptionTextSize,
                      color: IbColors.lightGrey),
                ),
              )
            ],
          ),
          trailing: const Icon(
            FontAwesomeIcons.comment,
            color: IbColors.accentColor,
          ),
        ),
      );
    }

    if (item.notification.type == IbNotification.kPollLike &&
        item.ibQuestion != null) {
      return IbCard(
        radius: 0,
        elevation: 0,
        margin: EdgeInsets.zero,
        color: item.notification.isRead ? Theme.of(context).primaryColor : null,
        child: ListTile(
          onTap: () async {
            if (!item.notification.isRead) {
              item.notification.isRead = true;
              await IbUserDbService().sendAlertNotification(item.notification);
            }
            Get.to(() => QuestionMainPage(
                  Get.put(
                      IbQuestionItemController(
                          rxIsSample: false.obs,
                          rxIbQuestion: item.ibQuestion!.obs,
                          rxIsExpanded: true.obs),
                      tag: item.ibQuestion!.id),
                ));
          },
          leading: IbUserAvatar(
            radius: 21,
            avatarUrl: item.avatarUrl,
          ),
          title: Text.rich(
            TextSpan(text: item.senderUser.username, children: const [
              TextSpan(
                  text: ' liked your poll:',
                  style: TextStyle(fontWeight: FontWeight.normal))
            ]),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(item.ibQuestion!.question),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  IbUtils.getAgoDateTimeString(
                      DateTime.fromMillisecondsSinceEpoch(
                          (item.notification.timestamp as Timestamp)
                              .millisecondsSinceEpoch)),
                  style: const TextStyle(
                      fontSize: IbConfig.kDescriptionTextSize,
                      color: IbColors.lightGrey),
                ),
              )
            ],
          ),
          trailing: const Icon(
            FontAwesomeIcons.thumbsUp,
            color: IbColors.errorRed,
          ),
        ),
      );
    }

    if (item.notification.type == IbNotification.kPollCommentLike &&
        item.ibQuestion != null &&
        item.ibComment != null) {
      return IbCard(
        radius: 0,
        elevation: 0,
        margin: EdgeInsets.zero,
        color: item.notification.isRead ? Theme.of(context).primaryColor : null,
        child: ListTile(
          onTap: () async {
            if (!item.notification.isRead) {
              item.notification.isRead = true;
              await IbUserDbService().sendAlertNotification(item.notification);
            }
            Get.to(() => QuestionMainPage(
                  Get.put(
                      IbQuestionItemController(
                          rxIsSample: false.obs,
                          rxIbQuestion: item.ibQuestion!.obs,
                          rxIsExpanded: true.obs),
                      tag: item.ibQuestion!.id),
                  toPage: ToPage.comment,
                ));
          },
          leading: IbUserAvatar(
            radius: 21,
            avatarUrl: item.avatarUrl,
          ),
          title: Text.rich(
            TextSpan(text: item.senderUser.username, children: const [
              TextSpan(
                  text: ' liked a comment you made on a poll:',
                  style: TextStyle(fontWeight: FontWeight.normal))
            ]),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(item.ibComment!.content),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  IbUtils.getAgoDateTimeString(
                      DateTime.fromMillisecondsSinceEpoch(
                          (item.notification.timestamp as Timestamp)
                              .millisecondsSinceEpoch)),
                  style: const TextStyle(
                      fontSize: IbConfig.kDescriptionTextSize,
                      color: IbColors.lightGrey),
                ),
              )
            ],
          ),
          trailing: const Icon(
            FontAwesomeIcons.heart,
            color: IbColors.errorRed,
          ),
        ),
      );
    }

    if (item.notification.type == IbNotification.kPollCommentReply &&
        item.ibQuestion != null &&
        item.ibComment != null) {
      return IbCard(
        radius: 0,
        elevation: 0,
        margin: EdgeInsets.zero,
        color: item.notification.isRead ? Theme.of(context).primaryColor : null,
        child: ListTile(
          onTap: () async {
            if (!item.notification.isRead) {
              item.notification.isRead = true;
              await IbUserDbService().sendAlertNotification(item.notification);
            }
            Get.to(() => QuestionMainPage(
                  Get.put(
                      IbQuestionItemController(
                          rxIsSample: false.obs,
                          rxIbQuestion: item.ibQuestion!.obs,
                          rxIsExpanded: true.obs),
                      tag: item.ibQuestion!.id),
                  toPage: ToPage.reply,
                  commentId: item.ibComment!.parentId,
                ));
          },
          leading: IbUserAvatar(
            radius: 21,
            avatarUrl: item.avatarUrl,
          ),
          title: Text.rich(
            TextSpan(text: item.senderUser.username, children: const [
              TextSpan(
                  text: ' replied a comment you made on a poll:',
                  style: TextStyle(fontWeight: FontWeight.normal))
            ]),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(item.ibComment!.content),
              if (item.notification.timestamp != null)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    IbUtils.getAgoDateTimeString(
                        DateTime.fromMillisecondsSinceEpoch(
                            (item.notification.timestamp as Timestamp)
                                .millisecondsSinceEpoch)),
                    style: const TextStyle(
                        fontSize: IbConfig.kDescriptionTextSize,
                        color: IbColors.lightGrey),
                  ),
                )
            ],
          ),
          trailing: const Icon(
            Icons.reply,
            color: IbColors.primaryColor,
          ),
        ),
      );
    }

    if (item.notification.type == IbNotification.kNewVote &&
        item.ibQuestion != null) {
      return IbCard(
        radius: 0,
        elevation: 0,
        margin: EdgeInsets.zero,
        color: item.notification.isRead ? Theme.of(context).primaryColor : null,
        child: ListTile(
          onTap: () async {
            if (!item.notification.isRead) {
              item.notification.isRead = true;
              await IbUserDbService().sendAlertNotification(item.notification);
            }
            Get.to(() => QuestionMainPage(
                  Get.put(
                      IbQuestionItemController(
                          rxIsSample: false.obs,
                          rxIbQuestion: item.ibQuestion!.obs,
                          rxIsExpanded: true.obs),
                      tag: item.ibQuestion!.id),
                ));
          },
          leading: IbUserAvatar(
            radius: 21,
            avatarUrl: item.avatarUrl,
          ),
          title: Text.rich(
            TextSpan(text: item.senderUser.username, children: const [
              TextSpan(
                  text: ' voted on your poll:',
                  style: TextStyle(fontWeight: FontWeight.normal))
            ]),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(item.ibQuestion!.question),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  IbUtils.getAgoDateTimeString(
                      DateTime.fromMillisecondsSinceEpoch(
                          (item.notification.timestamp as Timestamp)
                              .millisecondsSinceEpoch)),
                  style: const TextStyle(
                      fontSize: IbConfig.kDescriptionTextSize,
                      color: IbColors.lightGrey),
                ),
              )
            ],
          ),
          trailing: const Icon(
            FontAwesomeIcons.checkToSlot,
            color: IbColors.primaryColor,
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
