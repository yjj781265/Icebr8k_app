import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_question_stats_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_utils.dart';

/// show who voted stats
class IbQuestionStats extends StatelessWidget {
  final IbQuestionStatsController _controller;
  const IbQuestionStats(this._controller);

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      maxHeight: 300,
      child: SingleChildScrollView(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: _controller.stats.map((element) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: SingleChildScrollView(
                  child: Row(
                    children: [
                      _handleAvatars(element.users),
                      const SizedBox(
                        width: 16,
                      ),
                      _handleIbChoice(
                          choice: element.choice,
                          context: context,
                          isMe: element.users.indexWhere((element) =>
                                  element.id == IbUtils.getCurrentUid()!) !=
                              -1),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _handleAvatars(List<IbUser> users) {
    return SingleChildScrollView(
      child: Row(
        children: users.map((e) {
          return IbUserAvatar(
            avatarUrl: e.avatarUrl,
            radius: 12,
          );
        }).toList(),
      ),
    );
  }

  Widget _handleIbChoice(
      {required IbChoice choice,
      required BuildContext context,
      required bool isMe}) {
    final String heroTag = IbUtils.getUniqueId();
    return Row(
      children: [
        if (choice.url != null && choice.url!.isNotEmpty)
          GestureDetector(
            onDoubleTap: () {
              final Widget img = CachedNetworkImage(imageUrl: choice.url!);
              final Widget hero = Hero(
                tag: '$heroTag${choice.choiceId}',
                child: Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: img,
                  ),
                ),
              );

              /// show image preview
              IbUtils.showInteractiveViewer(hero, context);
            },
            child: Hero(
              tag: '$heroTag${choice.choiceId}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: choice.url!,
                  imageBuilder: (context, imageProvider) => Container(
                    width: IbConfig.kPicHeight,
                    height: IbConfig.kPicHeight,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        opacity: isMe ? 1.0 : 0.6,
                        image: imageProvider,
                        fit: BoxFit.scaleDown,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (choice.url != null && choice.url!.isNotEmpty)
          const SizedBox(
            width: 8,
          ),
        if (choice.content != null)
          Text(
            choice.content!,
            style: TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
          )
      ],
    );
  }
}
