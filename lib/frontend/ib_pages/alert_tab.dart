import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/notifications_controller.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class AlertTab extends StatelessWidget {
  final NotificationController _controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Obx(
          () => ListView.builder(
            itemBuilder: (context, index) {
              final IbNotification n = _controller.ibNotifications[index];
              return _handleNotificationType(n);
            },
            itemCount: _controller.ibNotifications.length,
          ),
        ),
      ),
    );
  }

  Widget _handleNotificationType(IbNotification notification) {
    if (notification.type == IbNotification.kFriendRequest) {
      return IbCard(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IbUserAvatar(
                    avatarUrl: notification.avatarUrl ?? '',
                    uid: notification.senderId,
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
                              notification.title,
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
                                        notification.timestampInMs),
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
                        if (notification.subtitle.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(notification.subtitle),
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
                      await _controller.declineFr(notification);
                    },
                    color: IbColors.errorRed,
                  )),
                  Expanded(
                    child: IbElevatedButton(
                        textTrKey: 'accept',
                        onPressed: () async {
                          await _controller.acceptFr(notification);
                        }),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    return SizedBox();
  }
}
