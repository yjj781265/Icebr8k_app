import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/word_cloud_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/tag_page.dart';
import 'package:lottie/lottie.dart';

class WordCloudPage extends StatefulWidget {
  final WordCloudController _controller;
  const WordCloudPage(this._controller, {Key? key}) : super(key: key);

  @override
  State<WordCloudPage> createState() => _WordCloudPageState();
}

class _WordCloudPageState extends State<WordCloudPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text("${widget._controller.user.username}'s Word Cloud"),
          actions: [
            IconButton(
                onPressed: () {
                  setState(() {});
                },
                icon: const Icon(Icons.refresh))
          ],
        ),
        body: Obx(() {
          if (widget._controller.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }

          if (widget._controller.userIbTagMap.isEmpty) {
            return Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/images/sloth_zen.json'),
                    Text(
                        '${widget._controller.user.username} has not answered any questions yet')
                  ],
                ),
              ),
            );
          }

          final List<String> tags =
              widget._controller.userIbTagMap.keys.toList();
          tags.sort((a, b) => (widget._controller.userIbTagMap[b] ?? 0)
              .compareTo(widget._controller.userIbTagMap[a] ?? 0));
          return Center(
            child: FittedBox(
              fit: BoxFit.cover,
              child: InteractiveViewer(
                child: Scatter(
                  fillGaps: true,
                  clipBehavior: Clip.none,
                  delegate: ArchimedeanSpiralScatterDelegate(),
                  children: tags
                      .take(16)
                      .toList()
                      .map((e) => TextButton(
                            child: Text(
                              e,
                              style: randomFont(e),
                            ),
                            onPressed: () {
                              Get.to(() => TagPage(
                                  Get.put(TagPageController(e), tag: e)));
                            },
                          ))
                      .toList(),
                ),
              ),
            ),
          );
        }));
  }

  TextStyle randomFont(String tag) {
    final List<String> tags = widget._controller.userIbTagMap.keys.toList();
    tags.sort((a, b) => (widget._controller.userIbTagMap[b] ?? 0)
        .compareTo(widget._controller.userIbTagMap[a] ?? 0));

    final int max = widget._controller.userIbTagMap[tags.first] ?? 1;
    final int count = widget._controller.userIbTagMap[tag] ?? 0;
    final fontStyles = [FontStyle.italic, FontStyle.normal];
    final fontWeights = [FontWeight.bold, FontWeight.normal];
    final fontSize =
        ((count.toDouble() / max.toDouble()) * 32) < IbConfig.kNormalTextSize
            ? IbConfig.kNormalTextSize
            : ((count.toDouble() / max.toDouble()) * 32);
    final fontColor = IbUtils().getRandomColor();
    fontStyles.shuffle();
    fontWeights.shuffle();

    return IbUtils()
        .getIbFonts(TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeights.first,
          color: fontColor,
        ))
        .first;
  }
}
