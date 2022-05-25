import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
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
    return AspectRatio(
      aspectRatio: 0.618,
      child: IbCard(
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (emoPic.url.isEmpty)
                    Container(
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
                        errorBuilder: (context, obj, stackTrace) {
                          return Container(
                            color: IbColors.lightGrey,
                            child: const Center(
                                child: Text('Failed to load image')),
                          );
                        },
                        fit: BoxFit.cover,
                      ),
                    ),
                  if (emoPic.url.isNotEmpty && emoPic.url.contains('http'))
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8)),
                      child: CachedNetworkImage(
                        errorWidget: (
                          context,
                          string,
                          d,
                        ) =>
                            Container(
                          color: IbColors.lightGrey,
                          child:
                              const Center(child: Text('Failed to load image')),
                        ),
                        progressIndicatorBuilder: (context, string, progress) {
                          return Center(
                            child: CircularProgressIndicator.adaptive(
                              value: progress.progress,
                            ),
                          );
                        },
                        imageUrl: emoPic.url,
                        fit: BoxFit.cover,
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
                        borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8)),
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
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: AutoSizeText(
                    emoPic.description,
                    overflow: TextOverflow.ellipsis,
                    maxFontSize: IbConfig.kNormalTextSize,
                    maxLines: 1,
                    style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontSize: IbConfig.kNormalTextSize,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
