import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_info_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/notifications_controller.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/chat_pages/circle_info.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class AlertTab extends StatelessWidget {
  final NotificationController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('Alert'),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => ListView.separated(
            itemBuilder: (context, index) {
              final NotificationItem item = _controller.items[index];
              return _handleNotificationType(item, context);
            },
            itemCount: _controller.items.length,
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 1,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _handleNotificationType(NotificationItem item, BuildContext context) {
    if (item.notification.type == IbNotification.kFriendRequest) {
      return IbCard(
        radius: 0,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IbUserAvatar(
                    avatarUrl: item.notification.avatarUrl ?? '',
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
                              item.notification.title,
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
                                    DateTime.fromMillisecondsSinceEpoch(
                                        item.notification.timestampInMs),
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
                        if (item.notification.subtitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(item.notification.subtitle),
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
    if (item.notification.type == IbNotification.kGroupInvite &&
        item.ibChat != null) {
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
        child: IbCard(
          radius: 0,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () async {
              item.notification.isRead = true;
              await IbUserDbService().sendAlertNotification(item.notification);
              _controller.items.refresh();
              Get.to(
                  () => CircleInfo(Get.put(CircleInfoController(item.ibChat!))),
                  transition: Transition.downToUp,
                  fullscreenDialog: true);
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Opacity(
                opacity: item.notification.isRead ? 0.5 : 1.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: IbUserAvatar(
                            radius: 21,
                            avatarUrl: item.notification.avatarUrl ?? '',
                            uid: item.notification.senderId,
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              item.notification.title,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: IbConfig.kNormalTextSize,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              IbUtils.getAgoDateTimeString(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      item.notification.timestampInMs)),
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
                                            color: Theme.of(context)
                                                .indicatorColor,
                                            fontSize:
                                                IbConfig.kSecondaryTextSize,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        '${item.ibChat!.memberCount} member(s)',
                                        style: const TextStyle(
                                            color: IbColors.lightGrey,
                                            fontSize:
                                                IbConfig.kDescriptionTextSize,
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
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
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
          ),
        ),
      );
    }
    return const SizedBox();
  }
}
