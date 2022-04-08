import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
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

class _IbMediaSlideState extends State<IbMediaSlide>
    with TickerProviderStateMixin {
  TabController? controller;
  @override
  void initState() {
    controller = TabController(length: widget.medias.length, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (controller != null) {
      controller!.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.medias.isEmpty) {
      return const SizedBox();
    }
    return Center(
      child: Column(
        children: [
          SizedBox(
            height: Get.width / 1.78,
            width: Get.width,
            child: TabBarView(
                controller: controller,
                children: widget.medias.map((e) {
                  return Container(
                      margin: const EdgeInsets.all(8),
                      color: Theme.of(context).backgroundColor,
                      child: _itemWidget(e));
                }).toList()),
          ),
          if (widget.medias.length > 1)
            TabPageSelector(
              indicatorSize: 6,
              controller: controller,
            ),
        ],
      ),
    );
  }

  Widget _itemWidget(IbMedia media) {
    late Widget mediaWidget;
    if (media.type == IbMedia.kPicType) {
      mediaWidget = media.url.contains('http')
          ? CachedNetworkImage(
              progressIndicatorBuilder: (context, string, progress) {
                return Center(
                  child: CircularProgressIndicator.adaptive(
                    value: progress.progress,
                  ),
                );
              },
              errorWidget: (
                context,
                string,
                d,
              ) =>
                  Container(
                color: IbColors.lightGrey,
                child: const Center(child: Text('Failed to load image')),
              ),
              imageUrl: media.url,
              height: Get.width * 1.78,
              width: Get.width,
              fit: BoxFit.fitHeight,
            )
          : Image.file(
              File(
                media.url,
              ),
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
      child: mediaWidget,
    );
  }
}
