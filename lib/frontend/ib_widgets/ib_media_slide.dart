import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_media.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';

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
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            height: (Get.width - 32) / 1.618,
            width: Get.width - 32,
            child: TabBarView(
                controller: controller,
                children: widget.medias.map((e) {
                  return _itemWidget(e);
                }).toList()),
          ),
          if (widget.medias.length > 1)
            Positioned(
              bottom: 3,
              child: Container(
                decoration: BoxDecoration(
                    color: IbColors.lightGrey.withOpacity(0.88),
                    borderRadius: const BorderRadius.all(Radius.circular(8))),
                child: TabPageSelector(
                  indicatorSize: 8,
                  controller: controller,
                ),
              ),
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
              imageUrl: media.url,
              fit: BoxFit.fitHeight,
            )
          : Image.file(
              File(
                media.url,
              ),
              fit: BoxFit.fitHeight,
            );
    } else {
      mediaWidget = const FlutterLogo();
    }

    return InkWell(
      onTap: () {
        Get.to(
            () => IbMediaViewer(
                urls: widget.medias.map((e) => e.url).toList(),
                currentIndex: widget.medias.indexOf(media)),
            transition: Transition.zoom);
      },
      child: mediaWidget,
    );
  }
}
