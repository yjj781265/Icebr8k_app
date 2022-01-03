import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

class IbMediaViewer extends StatefulWidget {
  final List<String> urls;
  final int currentIndex;
  const IbMediaViewer({required this.urls, required this.currentIndex});

  @override
  State<IbMediaViewer> createState() => _IbMediaViewerState();
}

class _IbMediaViewerState extends State<IbMediaViewer>
    with TickerProviderStateMixin {
  TabController? controller;
  @override
  void initState() {
    controller = TabController(length: widget.urls.length, vsync: this);
    controller?.index = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        TabBarView(
            controller: controller,
            children: widget.urls.map((e) {
              Widget img = const SizedBox();
              if (!e.contains('http')) {
                img = Image.file(
                  File(e),
                );
              } else {
                img = CachedNetworkImage(imageUrl: e);
              }

              return GestureDetector(
                onTap: () {
                  Get.back(canPop: false);
                },
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(8),
                  child: img,
                ),
              );
            }).toList()),
        Positioned(
            bottom: 16,
            child: SafeArea(
              child: Center(
                child: TabPageSelector(
                  controller: controller,
                ),
              ),
            )),
        Positioned(
          top: 64,
          right: 16,
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              onPressed: () {
                Get.back(canPop: false);
              },
              icon: const Icon(
                Icons.cancel,
                color: IbColors.errorRed,
              ),
            ),
          ),
        )
      ],
    );
  }
}
