import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/frontend/admin/edit_ib_cover_page.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/icebreaker_pages/ib_cover_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../../backend/controllers/admin_controllers/admin_main_controller.dart';

class EditIbCollectionMainPage extends StatelessWidget {
  final AdminMainController _controller = Get.put(AdminMainController());
  final bool isEdit;

  EditIbCollectionMainPage({this.isEdit = false, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icebreaker Collections'),
      ),
      body: Obx(
        () => Column(
          children: [
            Expanded(
              child: Obx(
                () => SingleChildScrollView(
                  child: StaggeredGrid.count(
                    crossAxisCount: 2,
                    children: _controller.ibCollections
                        .map((e) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Hero(
                                  tag: e.id,
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      width: Get.width / 2,
                                      height: (Get.width / 2) * 1.44,
                                      child: InkWell(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(8)),
                                        onTap: () => Get.to(() => IbCoverPage(
                                              e,
                                              isEdit: isEdit,
                                            )),
                                        child: IbCard(
                                          color: Color(e.bgColor),
                                          child: Center(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(4.0),
                                              child: AutoSizeText(
                                                e.name,
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                                minFontSize:
                                                    IbConfig.kNormalTextSize,
                                                maxFontSize:
                                                    IbConfig.kSloganSize,
                                                maxLines: 4,
                                                style: IbUtils.getIbFonts(
                                                    TextStyle(
                                                        fontSize: IbConfig
                                                            .kNormalTextSize,
                                                        fontStyle: e
                                                                .isItalic
                                                            ? FontStyle.italic
                                                            : FontStyle.normal,
                                                        color:
                                                            Color(e.textColor),
                                                        fontWeight:
                                                            FontWeight.bold))[e
                                                    .textStyleIndex],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isEdit)
                                  TextButton(
                                      onPressed: () {
                                        Get.to(() => EditIbCoverPage(e));
                                      },
                                      child: const Text('^ Edit Cover'))
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
            if (IbUtils.getCurrentIbUser() != null &&
                !IbUtils.getCurrentIbUser()!.isPremium)
              SafeArea(
                child: SizedBox(
                  height: 56,
                  child: AdWidget(ad: _controller.ad),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: isEdit
          ? FloatingActionButton(
              onPressed: () {
                Get.to(() => EditIbCoverPage(IbCollection(
                      id: IbUtils.getUniqueId(),
                      name: '',
                    )));
              },
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
    );
  }
}
