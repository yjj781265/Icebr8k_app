import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_page_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/backend/controllers/user_controllers/tag_page_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_pages/profile_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/tag_page.dart';

import '../../backend/controllers/user_controllers/people_nearby_controller.dart';
import '../ib_pages/chat_pages/chat_page.dart';
import '../ib_utils.dart';
import 'ib_linear_indicator.dart';
import 'ib_media_viewer.dart';

class PeopleNearbyCard extends StatefulWidget {
  final NearbyItem item;
  const PeopleNearbyCard(this.item);

  @override
  State<PeopleNearbyCard> createState() => _PeopleNearbyCardState();
}

class _PeopleNearbyCardState extends State<PeopleNearbyCard> {
  int currentIndex = 0;
  final CarouselController _controller = CarouselController();
  final PeopleNearbyController _peopleNearbyController = Get.find();
  @override
  Widget build(BuildContext context) {
    return IbCard(
        child: Column(
      children: [
        _cardStack(),
        _pageIndicator(),
        _actions(),
      ],
    ));
  }

  Widget _actions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              Get.to(() => ChatPage(Get.put(
                  ChatPageController(recipientId: widget.item.user.id),
                  tag: widget.item.user.id)));
            },
            backgroundColor: IbColors.primaryColor,
            child: const Icon(Icons.message),
          ),
          FloatingActionButton(
            heroTag: null,
            onPressed: () async {
              if (!widget.item.liked) {
                await _peopleNearbyController.likeProfile(widget.item);
              } else {
                await _peopleNearbyController.dislikeProfile(widget.item);
              }
            },
            backgroundColor: Colors.white,
            child: Icon(
              widget.item.liked ? Icons.favorite : Icons.favorite_border,
              color: IbColors.errorRed,
            ),
          ),
          FloatingActionButton.small(
            heroTag: null,
            onPressed: () {
              Get.to(() => ProfilePage(Get.put(
                  ProfileController(widget.item.user.id),
                  tag: widget.item.user.id)));
            },
            backgroundColor: IbColors.accentColor,
            child: const Icon(Icons.person),
          ),
        ],
      ),
    );
  }

  Widget _pageIndicator() {
    return Container(
      alignment: Alignment.center,
      width: 50,
      height: 20,
      child: IbCard(
        elevation: 0,
        color: Theme.of(context).backgroundColor.withOpacity(0.8),
        child: ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(currentIndex),
              child: Container(
                width: 8.8,
                height: 8.8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: IbColors.accentColor
                        .withOpacity(currentIndex == index ? 1.0 : 0.4)),
              ),
            );
          },
          itemCount: 2,
        ),
      ),
    );
  }

  Widget _userinfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.item.user.username,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: IbConfig.kPageTitleSize),
            ),
            const SizedBox(
              height: 2,
            ),
            AutoSizeText(
              '${widget.item.user.fName} • ${widget.item.user.gender} • ${IbUtils.calculateAge(widget.item.user.birthdateInMs ?? -1)}',
              maxLines: 1,
              textAlign: TextAlign.center,
              maxFontSize: IbConfig.kSecondaryTextSize,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: IbColors.lightGrey,
                  fontWeight: FontWeight.normal,
                  fontSize: IbConfig.kSecondaryTextSize),
            ),
            Text(
              '🔍${widget.item.user.intentions.join(' • ')}',
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            IbLinearIndicator(endValue: widget.item.compScore),
            const SizedBox(
              height: 2,
            ),
            Align(
                alignment: Alignment.centerRight,
                child: Text(
                  IbUtils.getDistanceString(
                      widget.item.distanceInMeter.toDouble()),
                  style: const TextStyle(
                    fontSize: IbConfig.kDescriptionTextSize,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.right,
                ))
          ],
        ),
      ),
    );
  }

  Widget _cardStack() {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16), topRight: Radius.circular(16)),
      child: CarouselSlider(
        carouselController: _controller,
        items: [
          Stack(
            alignment: Alignment.bottomLeft,
            children: [
              GestureDetector(
                onTap: () {
                  Get.to(
                      () => IbMediaViewer(
                          urls: [widget.item.user.avatarUrl], currentIndex: 0),
                      transition: Transition.zoom);
                },
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  width: Get.width,
                  height: Get.width / 0.7,
                  imageUrl: widget.item.user.avatarUrl,
                ),
              ),
              _userinfo(),
              Positioned(top: 32, child: _commonTagsWidget(context))
            ],
          ),
          Column(
            children: [
              Expanded(
                child: Padding(
                    padding: const EdgeInsets.only(
                        top: 32, right: 16, left: 16, bottom: 8),
                    child: AutoSizeText(
                      widget.item.user.bio,
                      maxLines: 10,
                      overflow: TextOverflow.ellipsis,
                      maxFontSize: IbConfig.kNormalTextSize,
                      style:
                          const TextStyle(fontSize: IbConfig.kNormalTextSize),
                    )),
              ),
              const Divider(
                thickness: 2,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _emoPics(context),
              ),
            ],
          )
        ],
        options: CarouselOptions(
            initialPage: currentIndex,
            viewportFraction: 1.0,
            aspectRatio: 0.7,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            },
            enableInfiniteScroll: false),
      ),
    );
  }

  Widget _commonTagsWidget(BuildContext context) {
    if (widget.item.commonTags.isEmpty) {
      return const SizedBox();
    }
    return SizedBox(
      width: Get.width,
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: widget.item.commonTags
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
                              () => TagPage(Get.put(TagPageController(element),
                                  tag: element)),
                              preventDuplicates: false);
                        },
                      ),
                    ))
                  ],
                ))
            .toList(),
      ),
    );
  }

  Widget _emoPics(BuildContext context) {
    if (widget.item.user.emoPics.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My EmoPics(${widget.item.user.emoPics.length})',
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
            items: widget.item.user.emoPics
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
}
