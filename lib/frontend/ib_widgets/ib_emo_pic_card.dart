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
    return IbCard(
        child: SizedBox(
      height: 160 * 1.618,
      width: 160,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              if (emoPic.url.isEmpty)
                Container(
                  width: 160,
                  height: 160 * 1.618 - 30,
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
                    width: 160,
                    height: 160 * 1.618 - 30,
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
                    width: 160,
                    height: 160 * 1.618 - 30,
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
                            transition: Transition.zoom);
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
