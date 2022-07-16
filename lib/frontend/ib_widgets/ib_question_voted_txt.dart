import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_colors.dart';

class IbQuestionVotedText extends StatelessWidget {
  final IbQuestionItemController _controller;
  const IbQuestionVotedText(this._controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.friendVotedList.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: InkWell(
            onTap: () {
              _showBtmSheet();
            },
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: AutoSizeText.rich(
                TextSpan(
                    text: _controller.friendVotedList.first.username,
                    children: [
                      if (_controller.friendVotedList.length > 1)
                        const TextSpan(
                            text: ' and ',
                            style: TextStyle(fontWeight: FontWeight.normal)),
                      if (_controller.friendVotedList.length > 1)
                        TextSpan(
                            text: '${_controller.friendVotedList.length - 1} '
                                'other friend(s) voted'),
                      if (_controller.friendVotedList.length == 1)
                        const TextSpan(text: ' voted'),
                    ]),
                style: const TextStyle(
                    color: IbColors.lightGrey,
                    fontWeight: FontWeight.normal,
                    fontSize: IbConfig.kSecondaryTextSize),
                maxLines: 1,
                maxFontSize: IbConfig.kSecondaryTextSize,
              ),
            ),
          ),
        );
      }
      return const SizedBox();
    });
  }

  void _showBtmSheet() {
    final Widget votedFriendsGrid = IbCard(
        child: SingleChildScrollView(
      child: SizedBox(
        height: 350,
        child: StaggeredGrid.count(
          crossAxisCount: 4,
          children: _controller.friendVotedList
              .map((element) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IbUserAvatar(avatarUrl: element.avatarUrl),
                      ),
                      Text(
                        element.username,
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  ))
              .toList(),
        ),
      ),
    ));
    Get.bottomSheet(votedFriendsGrid);
  }
}
