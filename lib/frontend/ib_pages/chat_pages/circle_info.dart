import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_info_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
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
        child: Obx(
          () => _controller.isLoading.isTrue
              ? const Center(
                  child: IbProgressIndicator(),
                )
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Obx(
                          () => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                if (_controller.rxIbChat.value.photoUrl.isEmpty)
                                  CircleAvatar(
                                    backgroundColor: IbColors.lightGrey,
                                    radius: 56,
                                    child: Text(
                                      _controller.rxIbChat.value.name[0],
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).indicatorColor,
                                          fontSize: 56,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  )
                                else
                                  GestureDetector(
                                    child: IbUserAvatar(
                                      avatarUrl:
                                          _controller.rxIbChat.value.photoUrl,
                                      radius: 56,
                                    ),
                                    onTap: () {
                                      Get.to(
                                          () => IbMediaViewer(urls: [
                                                _controller
                                                    .rxIbChat.value.photoUrl
                                              ], currentIndex: 0),
                                          fullscreenDialog: true,
                                          transition: Transition.zoom);
                                    },
                                  ),
                                Text(
                                  '${_controller.rxIbChat.value.memberCount} Member(s)',
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Text(
                                  _controller.rxIbChat.value.name,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: IbConfig.kPageTitleSize,
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Text(
                                  _controller.rxIbChat.value.description,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(
                                  height: 24,
                                ),
                                SingleChildScrollView(
                                  child: StaggeredGrid.count(
                                    crossAxisCount: 4,
                                    mainAxisSpacing: 16,
                                    children: _controller.memberScoreMap.keys
                                        .map((e) => IbUserAvatar(
                                              radius: 32,
                                              uid: e.id,
                                              avatarUrl: e.avatarUrl,
                                              compScore:
                                                  _controller.memberScoreMap[e],
                                            ))
                                        .toList()
                                      ..sort((a, b) => (b.compScore ?? 0)
                                          .compareTo(a.compScore ?? 0)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    /// max 88 member
                    if (_controller.rxIbChat.value.isCircle &&
                        _controller.rxIbChat.value.memberUids.length <
                            IbConfig.kCircleMaxMembers)
                      Container(
                        width: double.infinity,
                        height: 56,
                        margin: const EdgeInsets.all(16),
                        child: Obx(() {
                          if (_controller.hasInvite.isTrue &&
                              _controller.isMember.isFalse) {
                            return IbElevatedButton(
                                textTrKey: 'Join Circle',
                                onPressed: () async {
                                  _controller.joinCircle();
                                });
                          }

                          return IbElevatedButton(
                              color: _controller.requests.isNotEmpty
                                  ? Colors.orange
                                  : IbColors.accentColor,
                              textTrKey:
                                  _controller.rxIbChat.value.isPublicCircle
                                      ? 'Join Circle'
                                      : _controller.requests.isNotEmpty
                                          ? 'Cancel Request'
                                          : 'Request to Join Circle',
                              onPressed: () async {
                                if (_controller.rxIbChat.value.isPublicCircle) {
                                  _controller.joinCircle();
                                } else if (!_controller
                                        .rxIbChat.value.isPublicCircle &&
                                    _controller.rxIbChat.value.isCircle &&
                                    _controller.requests.isEmpty) {
                                  _showJoinRequestBtmSheet(context);
                                } else if (_controller.requests.isNotEmpty) {
                                  await _controller.cancelCircleRequest();
                                }
                              });
                        }),
                      )
                    else if (_controller.rxIbChat.value.memberUids.length >=
                        IbConfig.kCircleMaxMembers)
                      const Text(
                        'Circle is full',
                        style: TextStyle(
                            fontSize: IbConfig.kPageTitleSize,
                            color: IbColors.lightGrey),
                      )
                  ],
                ),
        ),
      ),
    );
  }

  void _showJoinRequestBtmSheet(BuildContext context) {
    _controller.editingController.clear();
    Get.bottomSheet(IbDialog(
      title: 'Request to Join Circle',
      subtitle: '',
      content: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(
            Radius.circular(16),
          ),
          color: Theme.of(context).backgroundColor,
        ),
        child: TextField(
          controller: _controller.editingController,
          maxLength: 300,
          minLines: 3,
          maxLines: 8,
          autofocus: true,
          decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Leave a request message(optional)'),
        ),
      ),
      onPositiveTap: () async {
        Get.back();
        await _controller.sendJoinCircleRequest();
      },
    ));
  }
}
