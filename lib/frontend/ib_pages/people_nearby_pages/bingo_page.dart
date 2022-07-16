import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:icebr8k/frontend/tag_page.dart';
import 'package:lottie/lottie.dart';

import '../../../backend/controllers/user_controllers/tag_page_controller.dart';
import '../../../backend/models/ib_user.dart';
import '../chat_pages/chat_page.dart';

class BingoPage extends StatelessWidget {
  final IbUser user;
  const BingoPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Column(
              children: [
                Flexible(
                    flex: 2, child: Lottie.asset('assets/images/bingo.json')),
                Flexible(
                  child: Text.rich(TextSpan(
                      text: 'You and ',
                      style:
                          const TextStyle(fontSize: IbConfig.kNormalTextSize),
                      children: [
                        TextSpan(
                            text: user.username,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        const TextSpan(
                            text: ' have liked each other',
                            style: TextStyle(fontWeight: FontWeight.normal))
                      ])),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IbUserAvatar(
                          avatarUrl: IbUtils().getCurrentIbUser()!.avatarUrl,
                          radius: 49,
                        ),
                        const SizedBox(
                          width: 16,
                        ),
                        IbUserAvatar(
                          avatarUrl: user.avatarUrl,
                          radius: 49,
                        )
                      ],
                    ),
                  ),
                ),
                Flexible(child: _commonTagsWidget(context)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: Get.width,
                child: IbElevatedButton(
                  textTrKey: 'Say Hi 👋',
                  onPressed: () {
                    Get.to(() => ChatPage(Get.put(
                        ChatPageController(recipientId: user.id),
                        tag: user.id)));
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commonTagsWidget(BuildContext context) {
    if (user.tags.isEmpty || IbUtils().getCurrentIbUser()!.tags.isEmpty) {
      return const SizedBox();
    }

    final commonTags = user.tags
        .toSet()
        .intersection(IbUtils().getCurrentIbUser()!.tags.toSet());
    if (commonTags.isEmpty) {
      return const SizedBox();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Common Tags',
            style: TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 8,
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: user.tags
                  .toSet()
                  .intersection(IbUtils().getCurrentIbUser()!.tags.toSet())
                  .take(4)
                  .map((element) => Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .backgroundColor
                                    .withOpacity(0.7),
                                border: Border.all(
                                    color: Theme.of(context).indicatorColor),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(16))),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(element,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.normal,
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
                                if (Get.isRegistered<TagPageController>(
                                    tag: element)) {
                                  return;
                                }

                                Get.to(
                                    () => TagPage(Get.put(
                                        TagPageController(element),
                                        tag: element)),
                                    preventDuplicates: false);
                              },
                            ),
                          ))
                        ],
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
