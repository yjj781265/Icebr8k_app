import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_question_item_controller.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';

import '../ib_colors.dart';

class IbQuestionMediaSlide extends StatefulWidget {
  final IbQuestionItemController itemController;
  const IbQuestionMediaSlide(this.itemController);

  @override
  State<IbQuestionMediaSlide> createState() => _IbQuestionMediaSlideState();
}

class _IbQuestionMediaSlideState extends State<IbQuestionMediaSlide> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.itemController.rxIbQuestion.value.medias.isEmpty) {
        return const SizedBox();
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CarouselSlider.builder(
              itemCount: widget.itemController.rxIbQuestion.value.medias.length,
              itemBuilder: (context, index, _) {
                return _itemWidget(
                    widget.itemController.rxIbQuestion.value.medias[index]);
              },
              options: CarouselOptions(
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                },
                enlargeCenterPage: true,
                viewportFraction: 0.9,
                enableInfiniteScroll: false,
                aspectRatio: 1.78,
              ),
            ),
          ),
          if (widget.itemController.rxIbQuestion.value.medias.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.itemController.rxIbQuestion.value.medias
                  .asMap()
                  .entries
                  .map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(entry.key),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: IbColors.accentColor
                            .withOpacity(_current == entry.key ? 0.9 : 0.4)),
                  ),
                );
              }).toList(),
            ),
          const SizedBox(
            height: 8,
          ),
        ],
      );
    });
  }

  Widget _itemWidget(IbMedia media) {
    late Widget mediaWidget;
    if (media.type == IbMedia.kPicType) {
      mediaWidget = media.url.contains('http')
          ? CachedNetworkImage(
              imageUrl: media.url,
              height: Get.width * 1.78,
              fit: BoxFit.fitHeight,
              progressIndicatorBuilder: (context, string, progress) {
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    value: progress.progress,
                  ),
                );
              },
              errorWidget: (context, str, obj) {
                return Container(
                  height: 100,
                  width: 50,
                  color: IbColors.lightGrey,
                  child: const Center(
                    child: Text('Failed to load image'),
                  ),
                );
              },
            )
          : Image.file(
              File(
                media.url,
              ),
              height: Get.width * 1.78,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, obj, stackTrace) {
                return Container(
                  color: IbColors.lightGrey,
                  child: const Center(child: Text('Failed to load image')),
                );
              },
            );
    } else {
      mediaWidget = const SizedBox();
    }

    return InkWell(
      onTap: () {
        Get.to(
            () => IbMediaViewer(
                urls: widget.itemController.rxIbQuestion.value.medias
                    .map((e) => e.url)
                    .toList(),
                currentIndex: widget.itemController.rxIbQuestion.value.medias
                    .indexOf(media)),
            transition: Transition.zoom,
            fullscreenDialog: true);
      },
      child: Stack(
        children: [
          Stack(
            children: [
              if (media.url.contains('http'))
                Image.network(
                  media.url,
                  height: Get.width * 1.78,
                  width: Get.width,
                  fit: BoxFit.fill,
                )
              else
                Image.file(
                  File(
                    media.url,
                  ),
                  height: Get.width * 1.78,
                  width: Get.width,
                  fit: BoxFit.fill,
                  errorBuilder: (context, obj, stackTrace) {
                    return Container(
                      color: IbColors.lightGrey,
                      child: const Center(child: Text('Failed to load image')),
                    );
                  },
                ),
              ClipRRect(
                child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    )),
              ),
            ],
          ),
          Center(child: mediaWidget),
        ],
      ),
    );
  }
}
