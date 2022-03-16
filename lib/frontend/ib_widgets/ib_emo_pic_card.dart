import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';

class IbEmoPicCard extends StatelessWidget {
  final IbEmoPic emoPic;
  final Function? onTap;
  final bool ignoreOnDoubleTap;

  const IbEmoPicCard(
      {required this.emoPic, this.onTap, this.ignoreOnDoubleTap = false});

  @override
  Widget build(BuildContext context) {
    final width = Get.width / 2.12;
    return IbCard(
        child: SizedBox(
      height: width * 1.618,
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              if (emoPic.url.isEmpty)
                Container(
                  height: width * 1.618 - 40,
                  width: width,
                  decoration: const BoxDecoration(
                      color: IbColors.lightGrey,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8))),
                  child: const Icon(
                    Icons.add,
                    size: 48,
                  ),
                ),
              if (emoPic.url.isNotEmpty && !emoPic.url.contains('http'))
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    File(emoPic.url),
                    fit: BoxFit.cover,
                    height: width * 1.618 - 40,
                    width: width,
                  ),
                ),
              if (emoPic.url.isNotEmpty && emoPic.url.contains('http'))
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)),
                  child: CachedNetworkImage(
                    imageUrl: emoPic.url,
                    fit: BoxFit.cover,
                    height: width * 1.618 - 40,
                    width: width,
                  ),
                ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Text(
                  emoPic.emoji,
                  style: const TextStyle(fontSize: IbConfig.kSloganSize),
                ),
              ),
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onDoubleTap: () {
                      if (ignoreOnDoubleTap) {
                        return;
                      }

                      if (emoPic.url.isNotEmpty) {
                        Get.to(
                            () => IbMediaViewer(
                                  urls: [emoPic.url],
                                  currentIndex: 0,
                                ),
                            transition: Transition.zoom,
                            fullscreenDialog: true);
                      }
                    },
                    onTap: () {
                      if (onTap == null) {
                        return;
                      }
                      onTap!();
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
              child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: RichText(
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                      text: emoPic.description,
                      style: TextStyle(
                          color: Theme.of(context).indicatorColor,
                          fontSize: IbConfig.kNormalTextSize,
                          fontWeight: FontWeight.bold),
                      children: const [])),
            ),
          )),
        ],
      ),
    ));
  }
}
