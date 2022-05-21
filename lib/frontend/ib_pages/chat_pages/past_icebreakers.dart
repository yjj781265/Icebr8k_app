import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/icebreaker_controller.dart';
import 'package:icebr8k/frontend/ib_pages/icebreaker_pages/icebreaker_main_page.dart';
import 'package:icebr8k/frontend/ib_widgets/icebreaker_card.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../backend/controllers/user_controllers/chat_page_controller.dart';
import '../../ib_config.dart';

class PastIcebreakers extends StatelessWidget {
  final ChatPageController _chatPageController;

  const PastIcebreakers(this._chatPageController);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Past Icebreakers'),
      ),
      body: Obx(() => SmartRefresher(
            enablePullUp:
                _chatPageController.pastIcebreakers.length >= IbConfig.kPerPage,
            onLoading: () async {
              await _chatPageController.loadPastIcebreakers();
            },
            onRefresh: () async {
              await _chatPageController.loadPastIcebreakers(isRefresh: true);
            },
            controller: _chatPageController.pastIcebreakerRefresh,
            child: StaggeredGrid.count(
              crossAxisCount: 2,
              children: _chatPageController.pastIcebreakers.keys
                  .toList()
                  .map(
                    (e) => InkWell(
                      onTap: () {
                        if (_chatPageController.pastIcebreakers[e] == null) {
                          return;
                        }
                        final controller = Get.put(
                            IcebreakerController(
                                _chatPageController.pastIcebreakers[e]!,
                                isEdit: false),
                            tag: e.collectionId);
                        controller.currentIndex.value = controller.icebreakers
                            .indexWhere((element) => element.id == e.id);
                        if (controller.currentIndex.value == -1) {
                          return;
                        }

                        Get.to(() => IcebreakerMainPage(controller));
                      },
                      child: IcebreakerCard(
                        minSize: 12,
                        maxSize: IbConfig.kNormalTextSize,
                        showCollectionName: false,
                        icebreaker: e,
                        ibCollection: _chatPageController.pastIcebreakers[e],
                      ),
                    ),
                  )
                  .toList(),
            ),
          )),
    );
  }
}
