import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/question_result_detail_controller.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/question_result_pages/question_result_detail_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../../../backend/controllers/user_controllers/ib_question_item_controller.dart';
import '../../ib_config.dart';

class QuestionResultMainPage extends StatelessWidget {
  final IbQuestionItemController _itemController;

  const QuestionResultMainPage(this._itemController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text('${_itemController.rxIbQuestion.value.pollSize} Polled'),
        ),
      ),
      body: Obx(() {
        final sortedList = _itemController.choiceUserMap.keys.toList();
        sortedList.sort((a, b) => _itemController.choiceUserMap[b]!.length
            .compareTo(_itemController.choiceUserMap[a]!.length));
        return ListView.builder(
          itemBuilder: (context, index) {
            final IbChoice choice = sortedList[index];
            return _itemWidget(
                choice: choice,
                ibUsers: _itemController.choiceUserMap[choice] ?? {});
          },
          itemCount: sortedList.length,
        );
      }),
    );
  }

  Widget _itemWidget({required IbChoice choice, required Set<IbUser> ibUsers}) {
    final int votes = _itemController.countMap[choice.choiceId] ?? 0;
    if (votes == 0) {
      return const SizedBox();
    }
    return InkWell(
      onTap: () {
        Get.to(() => QuestionResultDetailPage(Get.put(
            QuestionResultDetailPageController(
                itemController: _itemController, ibChoice: choice))));
      },
      child: Ink(
        color: Theme.of(Get.context!).backgroundColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _handleIbChoiceUI(choice),
                  Text(
                    '${_itemController.countMap[choice.choiceId]} vote(s)',
                    style: const TextStyle(color: IbColors.lightGrey),
                  ),
                ],
              ),
            ),
            Row(
                children: ibUsers.map((e) {
              if (ibUsers.toList().indexOf(e) == ibUsers.length - 1 &&
                  ibUsers.length - 1 > votes) {
                return Align(
                  widthFactor: 0.6,
                  child: CircleAvatar(
                    radius: 16,
                    child: Text('+${ibUsers.length - 1 - votes}'),
                  ),
                );
              }

              return Align(
                widthFactor: 0.6,
                child: IbUserAvatar(
                  disableOnTap: true,
                  radius: 16,
                  avatarUrl: e.avatarUrl,
                ),
              );
            }).toList()),
            const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _handleScType(IbChoice ibChoice) {
    if (_itemController.rxIbQuestion.value.questionType ==
        IbQuestion.kScaleOne) {
      return RatingBar.builder(
        initialRating: double.parse(ibChoice.content ?? '0'),
        ignoreGestures: true,
        itemSize: 20,
        itemBuilder: (context, _) => const Icon(
          Icons.star,
          color: Colors.amber,
        ),
        onRatingUpdate: (rating) {},
      );
    }

    if (_itemController.rxIbQuestion.value.questionType ==
        IbQuestion.kScaleTwo) {
      return RatingBar.builder(
        initialRating: double.parse(ibChoice.content ?? '0'),
        ignoreGestures: true,
        itemSize: 20,
        itemBuilder: (context, _) => const Icon(
          Icons.favorite,
          color: Colors.red,
        ),
        onRatingUpdate: (rating) {},
      );
    }

    if (_itemController.rxIbQuestion.value.questionType ==
        IbQuestion.kScaleThree) {
      return RatingBar.builder(
        initialRating: double.parse(ibChoice.content ?? '0'),
        ignoreGestures: true,
        itemSize: 20,
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

  Widget _handleIbChoiceUI(IbChoice choice) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: _handleScType(choice),
        ),
        if (choice.url != null && choice.url!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: InkWell(
              onTap: () {
                Get.to(
                    () => IbMediaViewer(urls: [choice.url!], currentIndex: 0),
                    transition: Transition.zoom);
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                child: CachedNetworkImage(
                  imageUrl: choice.url!,
                  fit: BoxFit.cover,
                  height: 40,
                  width: 40,
                ),
              ),
            ),
          ),
        if (choice.content != null)
          Text(
            choice.content!,
            style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
          )
      ],
    );
  }
}