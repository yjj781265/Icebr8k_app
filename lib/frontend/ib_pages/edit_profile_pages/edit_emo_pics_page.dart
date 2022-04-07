import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/edit_emo_pic_controller.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/edit_profile_pages/edit_emo_pics_detail_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';
import 'package:reorderables/reorderables.dart';

class EditEmoPicsPage extends StatelessWidget {
  final EditEmoPicController _controller;

  const EditEmoPicsPage(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit My EmoPics'),
      ),
      body: Obx(() => SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_controller.rxEmoPics.length > 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('Hold and drag to reorder'),
                  ),
                Expanded(
                  child: ReorderableWrap(
                    footer: IbEmoPicCard(
                      emoPic: IbEmoPic(
                        url: '',
                        id: '',
                        emoji: '',
                      ),
                      ignoreOnDoubleTap: true,
                      onTap: () {
                        Get.to(
                          () => EditEmoPicDetailPage(
                              IbEmoPic(
                                url: '',
                                id: IbUtils.getUniqueId(),
                                emoji: '',
                              ),
                              _controller),
                        );
                      },
                    ),
                    runAlignment: WrapAlignment.center,
                    children: _controller.rxEmoPics
                        .map((e) => Stack(
                              clipBehavior: Clip.none,
                              children: [
                                IbEmoPicCard(
                                  emoPic: e,
                                  onTap: () {
                                    Get.to(() =>
                                        EditEmoPicDetailPage(e, _controller));
                                  },
                                ),
                                Positioned(
                                    top: 0,
                                    right: 0,
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor:
                                          Theme.of(context).backgroundColor,
                                      child: IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: const Icon(
                                          Icons.remove_circle_outlined,
                                          color: IbColors.errorRed,
                                        ),
                                        onPressed: () async {
                                          await _controller.onRemoveCard(e);
                                        },
                                      ),
                                    ))
                              ],
                            ))
                        .toList(),
                    buildDraggableFeedback: (context, axis, item) {
                      return Material(color: Colors.transparent, child: item);
                    },
                    onReorder: (oldIndex, newIndex) async {
                      final item = _controller.rxEmoPics.removeAt(oldIndex);
                      _controller.rxEmoPics.insert(newIndex, item);
                      Get.dialog(const IbLoadingDialog(messageTrKey: 'update'),
                          barrierDismissible: false);
                      await IbUserDbService().updateEmoPics(
                          emoPics: _controller.rxEmoPics,
                          uid: IbUtils.getCurrentUid()!);
                      Get.back();
                    },
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
