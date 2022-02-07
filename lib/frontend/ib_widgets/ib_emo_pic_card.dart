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

  const IbEmoPicCard({required this.emoPic, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IbCard(
        child: SizedBox(
      height: 290,
      child: Column(
        children: [
          Stack(
            children: [
              if (emoPic.url.isEmpty)
                Container(
                  width: 160,
                  height: 260,
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
                Hero(
                  tag: emoPic.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.file(
                      File(emoPic.url),
                      fit: BoxFit.cover,
                      width: 160,
                      height: 260,
                    ),
                  ),
                ),
              if (emoPic.url.isNotEmpty && emoPic.url.contains('http'))
                Hero(
                  tag: emoPic.id,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: CachedNetworkImage(
                      imageUrl: emoPic.url,
                      width: 160,
                      height: 260,
                    ),
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
                      if (emoPic.url.isNotEmpty) {
                        Get.to(
                            () => IbMediaViewer(
                                  urls: [emoPic.url],
                                  currentIndex: 0,
                                  heroTag: emoPic.id,
                                ),
                            transition: Transition.noTransition);
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
            child: RichText(
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                    text: emoPic.description,
                    style: TextStyle(
                        color: Theme.of(context).indicatorColor,
                        fontSize: IbConfig.kPageTitleSize,
                        fontWeight: FontWeight.bold),
                    children: const [
                      TextSpan(
                          text: ' face',
                          style: TextStyle(color: IbColors.lightGrey))
                    ])),
          )),
        ],
      ),
    ));
  }
}
