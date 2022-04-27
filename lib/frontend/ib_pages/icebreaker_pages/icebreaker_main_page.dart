import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/icebreaker_controller.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/frontend/admin/edit_icebreaker_page.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/icebreaker_card.dart';
import 'package:reorderables/reorderables.dart';

import '../../ib_widgets/ib_card.dart';

class IcebreakerMainPage extends StatelessWidget {
  final IcebreakerController controller;
  const IcebreakerMainPage(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Obx(
        () => ReorderableWrap(
          footer: InkWell(
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            onTap: () {
              Get.to(() => EditIcebreakerPage(
                  Icebreaker(
                      text: '',
                      id: IbUtils.getUniqueId(),
                      collectionId: controller.ibCollection.id,
                      timestamp: null),
                  controller.ibCollection));
            },
            child: SizedBox(
                height: Get.width / 2 * 1.44,
                width: Get.width / 2,
                child: const IbCard(
                    color: IbColors.lightGrey, child: Icon(Icons.add))),
          ),
          onReorder: (int oldIndex, int newIndex) {},
          children: controller.icebreakers
              .map((e) => InkWell(
                    borderRadius: const BorderRadius.all(Radius.circular(16)),
                    onTap: () {
                      Get.to(
                          () => EditIcebreakerPage(e, controller.ibCollection));
                    },
                    child: SizedBox(
                        height: Get.width / 2 * 1.44,
                        width: Get.width / 2,
                        child: IcebreakerCard(
                          ibCollection: controller.ibCollection,
                          icebreaker: e,
                          showCollectionName: false,
                        )),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
