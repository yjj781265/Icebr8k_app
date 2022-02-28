import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_choice.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
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
          () => Text('${_itemController.totalPolled.value} Polled'),
        ),
      ),
      body: Obx(() {
        return ListView.builder(
          itemBuilder: (context, index) {
            final IbChoice choice =
                _itemController.choiceUserMap.keys.toList()[index];
            return _itemWidget(
                choice: choice,
                ibUsers: _itemController.choiceUserMap[choice] ?? []);
          },
          itemCount: _itemController.choiceUserMap.keys.length,
        );
      }),
    );
  }

  Widget _itemWidget(
      {required IbChoice choice, required List<IbUser> ibUsers}) {
    final int votes = _itemController.countMap[choice.choiceId] ?? 0;
    if (votes == 0) {
      return const SizedBox();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
          if (ibUsers.indexOf(e) == ibUsers.length - 1 &&
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
        }).toList())
      ]),
    );
  }

  Widget _handleIbChoiceUI(IbChoice choice) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (choice.url != null && choice.url!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
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
