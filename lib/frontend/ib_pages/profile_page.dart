import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController _controller;

  const ProfilePage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (_controller.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }
        return CustomScrollView(
          controller: _controller.scrollController,
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 250.0,
              collapsedHeight: 56,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).backgroundColor.withOpacity(0.8),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.cloud,
                          color: Theme.of(context).indicatorColor),
                    ),
                  ),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsetsDirectional.only(),
                title: Obx(() => AnimatedCrossFade(
                      alignment: Alignment.center,
                      crossFadeState: _controller.isCollapsing.isTrue
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      firstChild: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              child: Obx(
                                () => IbUserAvatar(
                                    compScore: _controller.compScore.value,
                                    radius: 32,
                                    avatarUrl:
                                        _controller.rxIbUser.value.avatarUrl),
                              ),
                              onTap: () {
                                Get.to(
                                    () => IbMediaViewer(urls: [
                                          _controller.rxIbUser.value.avatarUrl
                                        ], currentIndex: 0),
                                    transition: Transition.zoom,
                                    fullscreenDialog: true);
                              },
                            ),
                            IbCard(
                              radius: 8,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Obx(
                                  () => Text(
                                    _controller.rxIbUser.value.username,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      duration: const Duration(
                          milliseconds: IbConfig.kEventTriggerDelayInMillis),
                      reverseDuration: const Duration(
                          milliseconds: IbConfig.kEventTriggerDelayInMillis),
                      secondChild: Obx(() => Padding(
                            padding: EdgeInsets.only(
                                left: _controller.titlePadding.value),
                            child: LimitedBox(
                              maxWidth: 150,
                              child: Text(
                                _controller.rxIbUser.value.username,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          )),
                    )),
                background: Obx(
                  () => GestureDetector(
                    onTap: () {
                      Get.to(
                          () => IbMediaViewer(urls: [
                                if (_controller
                                    .rxIbUser.value.coverPhotoUrl.isEmpty)
                                  IbConfig.kDefaultCoverPhotoUrl
                                else
                                  _controller.rxIbUser.value.coverPhotoUrl
                              ], currentIndex: 0),
                          transition: Transition.zoom,
                          fullscreenDialog: true);
                    },
                    child: CachedNetworkImage(
                      imageUrl: _controller.rxIbUser.value.coverPhotoUrl.isEmpty
                          ? IbConfig.kDefaultCoverPhotoUrl
                          : _controller.rxIbUser.value.coverPhotoUrl,
                      fit: BoxFit.fill,
                      width: Get.width,
                      height: Get.width / 1.78,
                    ),
                  ),
                ),
              ),
            ),

            /// poll stats
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        color: Theme.of(context).backgroundColor,
                      ),
                      width: 88,
                      height: 88 / 1.618,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => Text(
                                IbUtils.getStatsString(
                                    _controller.commonAnswers.length),
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    fontSize: IbConfig.kPageTitleSize),
                              )),
                          const Text(
                            '👍 AGREE',
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: IbConfig.kDescriptionTextSize,
                                color: IbColors.lightGrey),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        color: Theme.of(context).backgroundColor,
                      ),
                      width: 88,
                      height: 88 / 1.618,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Obx(() => Text(
                                IbUtils.getStatsString(
                                    _controller.uncommonAnswers.length),
                                style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    fontSize: IbConfig.kPageTitleSize),
                              )),
                          const Text(
                            '👎 DISAGREE',
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontSize: IbConfig.kDescriptionTextSize,
                                color: IbColors.lightGrey),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),

            /// user info
            SliverToBoxAdapter(
              child: Obx(
                () => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        '${_controller.rxIbUser.value.fName} ${_controller.rxIbUser.value.lName} ',
                        style:
                            const TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                      Row(
                        children: [
                          Text(_controller.rxIbUser.value.gender),
                          if (_controller.rxIbUser.value.birthdateInMs != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                  '🎂 ${IbUtils.readableDateTime(DateTime.fromMillisecondsSinceEpoch(_controller.rxIbUser.value.birthdateInMs ?? 0))}'),
                            ),
                        ],
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      IbDescriptionText(text: _controller.rxIbUser.value.bio),
                    ],
                  ),
                ),
              ),
            ),

            /// emoPics
            SliverToBoxAdapter(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'My EmoPics',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: IbConfig.kPageTitleSize),
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: TextButton.icon(
                              onPressed: () {},
                              label: Text(
                                _controller.rxIbUser.value.emoPics.isEmpty
                                    ? ""
                                    : 'more'.tr,
                                style: const TextStyle(
                                    color: IbColors.primaryColor),
                              ),
                              icon: const Icon(
                                Icons.more_horiz,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Obx(() => Row(
                              children: _controller.rxIbUser.value.emoPics
                                  .map((e) => IbEmoPicCard(
                                        emoPic: e,
                                        onTap: () {
                                          Get.to(
                                              () => IbMediaViewer(
                                                    urls: [e.url],
                                                    currentIndex: 0,
                                                  ),
                                              transition: Transition.zoom,
                                              fullscreenDialog: true);
                                        },
                                        ignoreOnDoubleTap: true,
                                      ))
                                  .toList(),
                            )),
                      ),
                      if (_controller.rxIbUser.value.emoPics.isEmpty)
                        Center(
                            child: Text(
                          'nothing'.tr,
                          style: const TextStyle(color: IbColors.lightGrey),
                        ))
                    ],
                  )),
            ),
          ],
        );
      }),
    );
  }
}
