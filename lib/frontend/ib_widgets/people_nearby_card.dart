import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:icebr8k/frontend/tag_page.dart';

import '../../backend/controllers/user_controllers/people_nearby_controller.dart';
import '../ib_pages/chat_pages/chat_page.dart';
import 'ib_media_viewer.dart';

class PeopleNearbyCard extends StatelessWidget {
  final NearbyItem item;
  const PeopleNearbyCard(this.item);

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.618,
      child: IbCard(
        margin: EdgeInsets.zero,
        elevation: 0,
        child: Scrollbar(
          radius: const Radius.circular(16),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  IbUserAvatar(
                    avatarUrl: item.user.avatarUrl,
                    compScore: item.compScore,
                    radius: 48,
                    uid: item.user.id,
                  ),
                  AutoSizeText(
                    item.user.username,
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    maxFontSize: IbConfig.kSloganSize,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: IbConfig.kSloganSize),
                  ),
                  AutoSizeText(
                    '${item.user.fName} • ${item.user.gender} • ${IbUtils.calculateAge(item.user.birthdateInMs ?? -1)}',
                    maxLines: 1,
                    textAlign: TextAlign.center,
                    maxFontSize: IbConfig.kNormalTextSize,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: IbConfig.kNormalTextSize),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                    '🔍 ${item.user.intentions.join(' • ')}',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: IbColors.primaryColor,
                          size: 16,
                        ),
                        Text(
                          '${IbUtils.getDistanceString(item.distanceInMeter.toDouble())} away',
                          style: const TextStyle(color: IbColors.lightGrey),
                        ),
                      ],
                    ),
                  ),
                  IbDescriptionText(
                    text: item.user.bio,
                    textAlign: TextAlign.center,
                  ),
                  _actions(),
                  _commonTagsWidget(context),
                  _emoPics(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _commonTagsWidget(BuildContext context) {
    if (item.commonTags.isEmpty) {
      return const SizedBox();
    }
    return Align(
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You Both Followed',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: IbConfig.kNormalTextSize),
          ),
          const SizedBox(
            height: 8,
          ),
          Wrap(
            children: item.commonTags
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
          const Divider(
            thickness: 2,
          ),
        ],
      ),
    );
  }

  Widget _emoPics(BuildContext context) {
    if (item.user.emoPics.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My EmoPics(${item.user.emoPics.length})',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: IbConfig.kNormalTextSize),
          ),
          const SizedBox(
            height: 8,
          ),
          CarouselSlider(
            options: CarouselOptions(
                height: 250,
                padEnds: false,
                enableInfiniteScroll: false,
                viewportFraction: 0.4),
            items: item.user.emoPics
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
        ],
      );
    }
    return const SizedBox();
  }

  Widget _actions() {
    return Column(
      children: [
        const Divider(
          thickness: 2,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IbActionButton(
                color: IbColors.primaryColor,
                iconData: Icons.message,
                onPressed: () {
                  Get.to(() => ChatPage(Get.put(
                      ChatPageController(recipientId: item.user.id),
                      tag: item.user.id)));
                },
                text: 'Message'),
            IbActionButton(
                color: IbColors.accentColor,
                iconData: Icons.remove_red_eye_rounded,
                onPressed: () {
                  Get.to(() => ProfilePage(Get.put(
                      ProfileController(item.user.id),
                      tag: item.user.id)));
                },
                text: 'View Profile'),
          ],
        ),
        const Divider(
          thickness: 2,
        ),
      ],
    );
  }
}
