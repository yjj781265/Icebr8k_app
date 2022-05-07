import 'package:flutter/material.dart';
import 'package:flutter_scatter/flutter_scatter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/word_cloud_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/tag_page.dart';
import 'package:lottie/lottie.dart';

class WordCloudPage extends StatelessWidget {
  final WordCloudController _controller;
  const WordCloudPage(this._controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text("${_controller.user.username}'s Word Cloud"),
        ),
        body: Obx(() {
          if (_controller.isLoading.isTrue) {
            return const Center(
              child: IbProgressIndicator(),
            );
          }

          if (_controller.userIbTagMap.isEmpty) {
            return Center(
              child: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('assets/images/sloth_zen.json'),
                    Text(
                        '${_controller.user.username} has not answered any questions yet')
                  ],
                ),
              ),
            );
          }

          final List<String> tags = _controller.userIbTagMap.keys.toList();
          tags.sort((a, b) => (_controller.userIbTagMap[b] ?? 0)
              .compareTo(_controller.userIbTagMap[a] ?? 0));
          return Center(
            child: FittedBox(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
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
                                Get.to(() =>
                                    TagPage(Get.put(TagPageController(e))));
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          );
        }));
  }

  TextStyle randomFont(String tag) {
    final List<String> tags = _controller.userIbTagMap.keys.toList();
    tags.sort((a, b) => (_controller.userIbTagMap[b] ?? 0)
        .compareTo(_controller.userIbTagMap[a] ?? 0));

    final int max = _controller.userIbTagMap[tags.first] ?? 1;
    final int count = _controller.userIbTagMap[tag] ?? 0;
    final fontStyles = [FontStyle.italic, FontStyle.normal];
    final fontWeights = [FontWeight.bold, FontWeight.normal];
    final fontSize =
        ((count.toDouble() / max.toDouble()) * 32) < IbConfig.kNormalTextSize
            ? IbConfig.kNormalTextSize
            : ((count.toDouble() / max.toDouble()) * 32);
    final fontColor = IbUtils.getRandomColor();
    fontStyles.shuffle();
    fontWeights.shuffle();

    final fonts = [
      GoogleFonts.aBeeZee(
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize,
          color: fontColor),
      GoogleFonts.baloo2(
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize,
          color: fontColor),
      GoogleFonts.cabin(
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize,
          color: fontColor),
      GoogleFonts.dancingScript(
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize,
          color: fontColor),
      GoogleFonts.eagleLake(
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          color: fontColor,
          fontSize: fontSize),
      GoogleFonts.fascinate(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.gabriela(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.hurricane(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.iceberg(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.jura(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.kameron(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.lato(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.mada(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.newsCycle(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.openSans(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.pacifico(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.quantico(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.roboto(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.sacramento(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.theGirlNextDoor(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.ubuntu(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.vampiroOne(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.workSans(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.xanhMono(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.yujiMai(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
      GoogleFonts.zenLoop(
          color: fontColor,
          fontWeight: fontWeights.first,
          fontStyle: fontStyles.first,
          fontSize: fontSize),
    ];

    fonts.shuffle();
    return fonts.first;
  }
}
