import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../backend/controllers/user_controllers/tag_page_controller.dart';
import '../../ib_colors.dart';
import '../../ib_config.dart';
import '../../tag_page.dart';

class FollowedTagsPage extends StatelessWidget {
  final List<String> tags;
  final String username;
  const FollowedTagsPage(this.tags, this.username, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (tags.isNotEmpty) {
      tags.sort();
    }

    return Scaffold(
        appBar: AppBar(
          title: Text("$username's Followed Tags"),
        ),
        body: tags.isEmpty
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.asset('assets/images/monkey_zen.json')),
                    Text(
                      '$username has not followed any tags yet',
                      style: const TextStyle(
                        color: IbColors.lightGrey,
                        fontSize: IbConfig.kNormalTextSize,
                      ),
                    ),
                  ],
                ),
              )
            : Wrap(
                children: tags
                    .map(
                      (e) => Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                                color: Theme.of(context).backgroundColor,
                                border: Border.all(
                                    color: Theme.of(context).indicatorColor),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(e,
                                  style: const TextStyle(
                                      fontSize: IbConfig.kDescriptionTextSize)),
                            ),
                          ),
                          Positioned.fill(
                              child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              onTap: () {
                                Get.to(() => TagPage(
                                    Get.put(TagPageController(e), tag: e)));
                              },
                            ),
                          ))
                        ],
                      ),
                    )
                    .toList(),
              ));
  }
}
