import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/icebreaker_controller.dart';
import 'package:icebr8k/backend/models/icebreaker_models/icebreaker.dart';
import 'package:icebr8k/backend/services/admin_services/ib_admin_db_service.dart';
import 'package:icebr8k/frontend/admin/edit_icebreaker_page.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/icebreaker_card.dart';
import 'package:lottie/lottie.dart';
import 'package:reorderables/reorderables.dart';

import '../../ib_widgets/ib_card.dart';

class IcebreakerMainPage extends StatelessWidget {
  final IcebreakerController controller;
  const IcebreakerMainPage(this.controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Get.back(result: controller.ibCollection);
          },
        ),
        title: Text(controller.ibCollection.name),
        actions: [
          Obx(() {
            if (controller.hasEditAccess.isTrue) {
              return IconButton(
                  onPressed: () {
                    controller.isEditing.value = !controller.isEditing.value;
                  },
                  icon: controller.isEditing.isFalse
                      ? const Icon(Icons.edit)
                      : const Icon(Icons.slideshow));
            }

            return const SizedBox();
          })
        ],
      ),
      body: Obx(() {
        if (controller.isEditing.isFalse) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (controller.isShuffling.isTrue)
                Expanded(
                  child: Center(
                    child: SizedBox(
                        width: 300,
                        height: 300,
                        child: Lottie.asset('assets/images/dice.json')),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Stack(
                      children: [
                        CarouselSlider.builder(
                          itemBuilder:
                              (BuildContext context, int index, int num) {
                            return Stack(
                              children: [
                                IcebreakerCard(
                                    ibCollection: controller.ibCollection,
                                    showCollectionName: false,
                                    icebreaker: controller.icebreakers[index]),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: IbCard(
                                    elevation: 0,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                          '${controller.currentIndex.value + 1}/${controller.icebreakers.length}'),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                          carouselController: controller.carouselController,
                          options: CarouselOptions(
                              initialPage: controller.currentIndex.value,
                              aspectRatio: 1.44,
                              height: Get.width * 1.44,
                              viewportFraction: 0.95,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                              onPageChanged: (index, reason) {
                                controller.currentIndex.value = index;
                              }),
                          itemCount: controller.icebreakers.length,
                        ),
                      ],
                    ),
                  ),
                ),
              SafeArea(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                          child: controller.currentIndex.value != 0 &&
                                  controller.isShuffling.isFalse
                              ? SizedBox(
                                  height: 48,
                                  child: IbElevatedButton(
                                      textTrKey: 'Prev',
                                      color: IbColors.errorRed,
                                      onPressed: () {
                                        controller.carouselController
                                            .previousPage();
                                      }),
                                )
                              : const SizedBox()),
                      Expanded(
                          flex: 3,
                          child: SizedBox(
                            height: 48,
                            child: IbElevatedButton(
                                textTrKey: 'Shuffle 🎲',
                                disabled: controller.isShuffling.isTrue,
                                onPressed: () async {
                                  await controller.shuffleCards();
                                }),
                          )),
                      Expanded(
                          child: controller.currentIndex.value !=
                                      controller.icebreakers.length - 1 &&
                                  controller.isShuffling.isFalse
                              ? SizedBox(
                                  height: 48,
                                  child: IbElevatedButton(
                                      disabled: controller.isShuffling.isTrue,
                                      textTrKey: 'Next',
                                      color: IbColors.primaryColor,
                                      onPressed: () {
                                        controller.carouselController
                                            .nextPage();
                                      }),
                                )
                              : const SizedBox()),
                    ],
                  ),
                ),
              )
            ],
          );
        }

        return Material(
          color: Colors.transparent,
          child: Scrollbar(
            trackVisibility: true,
            child: ReorderableWrap(
              controller: controller.scrollController,
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
              onReorder: (int oldIndex, int newIndex) async {
                final item = controller.icebreakers.removeAt(oldIndex);
                controller.icebreakers.insert(newIndex, item);
                controller.ibCollection.icebreakers = controller.icebreakers;
                await IbAdminDbService()
                    .addIcebreakerCollection(controller.ibCollection);
              },
              children: controller.icebreakers
                  .map((e) => InkWell(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(16)),
                        onTap: () {
                          Get.to(() =>
                              EditIcebreakerPage(e, controller.ibCollection));
                        },
                        child: Hero(
                          tag: e.id,
                          child: SizedBox(
                              height: Get.width / 2 * 1.44,
                              width: Get.width / 2,
                              child: IcebreakerCard(
                                ibCollection: controller.ibCollection,
                                icebreaker: e,
                                showCollectionName: false,
                              )),
                        ),
                      ))
                  .toList(),
            ),
          ),
        );
      }),
      floatingActionButton: Obx(
        () {
          if (controller.isEditing.isTrue) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    Get.to(() => EditIcebreakerPage(
                        Icebreaker(
                            text: '',
                            id: IbUtils.getUniqueId(),
                            collectionId: controller.ibCollection.id,
                            timestamp: null),
                        controller.ibCollection));
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(
                  width: 16,
                ),
                FloatingActionButton(
                  heroTag: null,
                  mini: true,
                  onPressed: () {
                    if (controller.scrollController.hasClients) {
                      final position =
                          controller.scrollController.position.maxScrollExtent;
                      controller.scrollController.jumpTo(position);
                    }
                  },
                  child: const Icon(Icons.arrow_circle_down),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
