import 'dart:io';
import 'dart:ui';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';

import '../ib_colors.dart';

class IbMediaSlide extends StatefulWidget {
  final List<IbMedia> medias;

  const IbMediaSlide(this.medias);

  @override
  State<IbMediaSlide> createState() => _IbMediaSlideState();
}

class _IbMediaSlideState extends State<IbMediaSlide> {
  final CarouselController _controller = CarouselController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.medias.isEmpty) {
      return const SizedBox();
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: CarouselSlider.builder(
            itemCount: widget.medias.length,
            itemBuilder: (context, index, num) {
              return _itemWidget(widget.medias[index]);
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
        if (widget.medias.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.medias.asMap().entries.map((entry) {
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
      ],
    );
  }

  Widget _itemWidget(IbMedia media) {
    late Widget mediaWidget;
    if (media.type == IbMedia.kPicType) {
      mediaWidget = media.url.contains('http')
          ? Image.network(
              media.url,
              height: Get.width * 1.78,
              fit: BoxFit.fitHeight,
              errorBuilder: (context, obj, stackTrace) {
                return Container(
                  color: IbColors.lightGrey,
                  child: const Center(child: Text('Failed to load image')),
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
                urls: widget.medias.map((e) => e.url).toList(),
                currentIndex: widget.medias.indexOf(media)),
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
