import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_stats_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_utils.dart';
import 'ib_media_viewer.dart';

/// show stats for comparision between two users
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _controller.stats.map((element) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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

  Widget _handleScType(IbChoice choice) {
    final double initRating = double.parse(choice.content!);
    if (_controller.ibQuestion.questionType == IbQuestion.kScaleOne) {
      return RatingBar.builder(
        ignoreGestures: true,
        itemSize: 20,
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        initialRating: initRating,
        onRatingUpdate: (rating) {},
      );
    }

    if (_controller.ibQuestion.questionType == IbQuestion.kScaleTwo) {
      return RatingBar.builder(
        ignoreGestures: true,
        itemSize: 20,
        initialRating: initRating,
        itemBuilder: (context, _) => const Icon(
          Icons.favorite,
          color: Colors.red,
        ),
        onRatingUpdate: (rating) {},
      );
    }

    if (_controller.ibQuestion.questionType == IbQuestion.kScaleThree) {
      return RatingBar.builder(
        ignoreGestures: true,
        itemSize: 20,
        initialRating: initRating,
        itemBuilder: (context, index) {
          switch (index) {
            case 0:
              return const Icon(
                Icons.sentiment_very_dissatisfied,
                color: Colors.red,
              );
            case 1:
              return const Icon(
                Icons.sentiment_dissatisfied,
                color: Colors.redAccent,
              );
            case 2:
              return const Icon(
                Icons.sentiment_neutral,
                color: Colors.amber,
              );
            case 3:
              return const Icon(
                Icons.sentiment_satisfied,
                color: Colors.lightGreen,
              );
            case 4:
              return const Icon(
                Icons.sentiment_very_satisfied,
                color: Colors.green,
              );
            default:
              return const SizedBox();
          }
        },
        onRatingUpdate: (rating) {},
      );
    }

    return const SizedBox();
  }

  Widget _handleIbChoice(
      {required IbChoice choice,
      required BuildContext context,
      required bool isMe}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_controller.ibQuestion.questionType.contains('sc'))
          _handleScType(choice),
        if (choice.url != null && choice.url!.isNotEmpty)
          GestureDetector(
            onTap: () {
              Get.to(
                  () => IbMediaViewer(
                        urls: [choice.url!],
                        currentIndex: 0,
                      ),
                  transition: Transition.zoom,
                  fullscreenDialog: true);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: choice.url!,
                imageBuilder: (context, imageProvider) => Container(
                  width: IbConfig.kMcPicSize,
                  height: IbConfig.kMcPicSize,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      opacity: isMe ? 1.0 : 0.6,
                      image: imageProvider,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(
          width: 4,
        ),
        if (choice.content != null)
          Text(
            choice.content!,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                fontWeight: isMe ? FontWeight.bold : FontWeight.normal),
          )
      ],
    );
  }
}
