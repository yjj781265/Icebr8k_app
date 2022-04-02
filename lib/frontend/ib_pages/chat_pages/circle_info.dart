import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_info_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_media_viewer.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../../ib_colors.dart';

class CircleInfo extends StatelessWidget {
  final CircleInfoController _controller;

  const CircleInfo(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Obx(
                  () => Column(
                    children: [
                      if (_controller.ibChat.photoUrl.isEmpty)
                        CircleAvatar(
                          backgroundColor: IbColors.lightGrey,
                          radius: 56,
                          child: Text(
                            _controller.ibChat.name[0],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Theme.of(context).indicatorColor,
                                fontSize: 56,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        GestureDetector(
                          child: IbUserAvatar(
                            avatarUrl: _controller.ibChat.photoUrl,
                            radius: 56,
                          ),
                          onTap: () {
                            Get.to(
                                () => IbMediaViewer(
                                    urls: [_controller.ibChat.photoUrl],
                                    currentIndex: 0),
                                fullscreenDialog: true,
                                transition: Transition.zoom);
                          },
                        ),
                      Text(
                        '${_controller.ibChat.memberCount} Member(s)',
                        style: const TextStyle(color: IbColors.lightGrey),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Text(
                        _controller.ibChat.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: IbConfig.kPageTitleSize,
                        ),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(_controller.ibChat.description),
                      const SizedBox(
                        height: 24,
                      ),
                      if (_controller.isLoading.value)
                        const Center(
                          child: IbProgressIndicator(),
                        )
                      else
                        StaggeredGrid.count(
                          crossAxisCount: 4,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          children: _controller.memberScoreMap.keys
                              .map((e) => IbUserAvatar(
                                    radius: 32,
                                    uid: e.id,
                                    avatarUrl: e.avatarUrl,
                                    compScore: _controller.memberScoreMap[e],
                                  ))
                              .toList()
                            ..sort((a, b) =>
                                (b.compScore ?? 0).compareTo(a.compScore ?? 0)),
                        )
                    ],
                  ),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.all(8),
              child: IbElevatedButton(
                  textTrKey: 'Join Circle',
                  onPressed: () async {
                    await _controller.joinCircle();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
