import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/profile_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_description_text.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class ProfilePage extends StatelessWidget {
  final ProfileController _controller;

  const ProfilePage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //1
      body: CustomScrollView(
        slivers: <Widget>[
          //2
          SliverAppBar(
            automaticallyImplyLeading: false,
            expandedHeight: 250.0,
            collapsedHeight: 100,
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).backgroundColor.withOpacity(0.8),
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.message_rounded,
                            color: Theme.of(context).indicatorColor))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).backgroundColor.withOpacity(0.8),
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.person_add,
                            color: Theme.of(context).indicatorColor))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).backgroundColor.withOpacity(0.8),
                    child: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.cloud,
                            color: Theme.of(context).indicatorColor))),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.all(8),
              title: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    child: Obx(
                      () => IbUserAvatar(
                        radius: 32,
                        avatarUrl: _controller.avatarUrl.value,
                        compScore: 0.32,
                      ),
                    ),
                    onTap: () {
                      Get.to(
                          () => IbMediaViewer(
                              urls: [IbUtils.getCurrentIbUser()!.avatarUrl],
                              currentIndex: 0),
                          transition: Transition.zoom);
                    },
                  ),
                  IbCard(
                    radius: 8,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        IbUtils.getCurrentIbUser()!.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              background: CachedNetworkImage(
                imageUrl: _controller.coverPhotoUrl.value.isEmpty
                    ? IbConfig.kDefaultCoverPhotoUrl
                    : _controller.coverPhotoUrl.value,
                fit: BoxFit.fill,
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
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: Theme.of(context).backgroundColor,
                    ),
                    width: 120,
                    height: 120 / 1.618,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => Text(
                              IbUtils.getStatsString(
                                  _controller.answeredSize.value),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: IbConfig.kPageTitleSize),
                            )),
                        const Text('ANSWERED')
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                      color: Theme.of(context).backgroundColor,
                    ),
                    width: 120,
                    height: 120 / 1.618,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => Text(
                              IbUtils.getStatsString(
                                  _controller.askedSize.value),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: IbConfig.kPageTitleSize),
                            )),
                        const Text('ASKED')
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
                      _controller.name.value,
                      style:
                          const TextStyle(fontSize: IbConfig.kNormalTextSize),
                    ),
                    IbDescriptionText(text: _controller.bio.value),
                  ],
                ),
              ),
            ),
          ),

          /// emoPics
          if (_controller.emoPics.isNotEmpty)
            SliverToBoxAdapter(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: _handleEmoPic()),
                      ),
                    ],
                  )),
            ),
          if (_controller.emoPics.isNotEmpty)
            SliverToBoxAdapter(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: _handleEmoPic()),
                      ),
                    ],
                  )),
            ),
          if (_controller.emoPics.isNotEmpty)
            SliverToBoxAdapter(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: _handleEmoPic()),
                      ),
                    ],
                  )),
            ),
          if (_controller.emoPics.isNotEmpty)
            SliverToBoxAdapter(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(children: _handleEmoPic()),
                      ),
                    ],
                  )),
            ),
        ],
      ),
    );
  }

  List<Widget> _handleEmoPic() {
    final List<Widget> list = [];
    list.addAll(_controller.emoPics
        .getRange(
            0, _controller.emoPics.length > 3 ? 4 : _controller.emoPics.length)
        .map((element) => IbEmoPicCard(
              emoPic: element,
              ignoreOnDoubleTap: true,
              onTap: () {
                Get.to(
                    () => IbMediaViewer(
                          urls: [element.url],
                          currentIndex: 0,
                          heroTag: element.id,
                        ),
                    transition: Transition.noTransition);
              },
            ))
        .toList());

    if (_controller.emoPics.length > 3) {
      list.add(Padding(
        padding: const EdgeInsets.all(16.0),
        child: IbActionButton(
            color: IbColors.primaryColor,
            iconData: Icons.arrow_forward,
            onPressed: () {},
            text: 'See More'),
      ));
    }
    return list;
  }
}
