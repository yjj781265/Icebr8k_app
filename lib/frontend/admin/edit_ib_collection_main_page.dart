import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/frontend/admin/edit_ib_cover_page.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../../backend/controllers/admin_controllers/admin_main_controller.dart';

class EditIbCollectionMainPage extends StatelessWidget {
  final AdminMainController _controller = Get.find();
  EditIbCollectionMainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Icebreaker Collections'),
      ),
      body: StaggeredGrid.count(
        crossAxisCount: 4,
        children: _controller.ibCollections
            .map((e) => Column(
                  children: [
                    IbCard(
                      color: Color(e.bgColor),
                      child: AutoSizeText(
                        e.name,
                        minFontSize: IbConfig.kNormalTextSize,
                        maxFontSize: IbConfig.kSloganSize,
                        maxLines: 4,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(e.textColor)),
                      ),
                    ),
                    TextButton(
                        onPressed: () {}, child: const Text('Edit Cover'))
                  ],
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => EditIbCoverPage(IbCollection(
                name: '',
                creatorId: '',
              )));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
