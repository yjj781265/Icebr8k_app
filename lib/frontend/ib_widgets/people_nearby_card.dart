import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:icebr8k/frontend/tag_page.dart';
import 'package:lottie/lottie.dart';

import 'ib_media_viewer.dart';

class PeopleNearbyCard extends StatelessWidget {
  IbUser user = IbUtils.getCurrentIbUser()!;
  int distance = 1000;
  List<String> commonTags = ['dog', 'cat'];

  @override
  Widget build(BuildContext context) {
    return IbCard(
      child: Scrollbar(
        radius: const Radius.circular(16),
        controller: ScrollController(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                IbUserAvatar(
                  avatarUrl: user.avatarUrl,
                  compScore: 0.98,
                  radius: 40,
                  uid: user.id,
                ),
                AutoSizeText(
                  user.username,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxFontSize: IbConfig.kPageTitleSize,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: IbConfig.kPageTitleSize),
                ),
                AutoSizeText(
                  '${user.fName} • ${user.gender} • ${IbUtils.calculateAge(user.birthdateInMs ?? -1)}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  maxFontSize: IbConfig.kNormalTextSize,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: IbConfig.kNormalTextSize),
                ),
                const SizedBox(
                  height: 4,
                ),
                IbDescriptionText(
                  text: user.bio,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 16,
                ),
                _commonTagsWidget(context),
                const Divider(
                  thickness: 2,
                  height: 16,
                ),
                _emoPics(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _commonTagsWidget(BuildContext context) {
    if (commonTags.isEmpty) {
      return const SizedBox();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Common Tags',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: IbConfig.kNormalTextSize),
          ),
          const SizedBox(
            height: 8,
          ),
          Wrap(
            children: commonTags
                .map((element) => Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                              color: Theme.of(context).backgroundColor,
                              border: Border.all(
                                  color: Theme.of(context).indicatorColor),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(16))),
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
        ],
      ),
    );
  }

  Widget _emoPics(BuildContext context) {
    if (user.emoPics.isNotEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My EmoPics(${user.emoPics.length})',
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: IbConfig.kNormalTextSize),
            ),
            const SizedBox(
              height: 8,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: user.emoPics
                    .map((e) => IbEmoPicCard(
                          emoPic: e,
                          ignoreOnDoubleTap: true,
                          onTap: () {
                            Get.to(
                                () => IbMediaViewer(
                                      urls: [e.url],
                                      currentIndex: 0,
                                    ),
                                transition: Transition.zoom,
                                fullscreenDialog: true);
                          },
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
      );
    }
    return Center(
      child: SizedBox(
          width: 300,
          height: 300,
          child: Lottie.asset('assets/images/monkey_zen.json')),
    );
  }
}
