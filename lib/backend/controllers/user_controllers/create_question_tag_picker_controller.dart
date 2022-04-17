import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';
import 'package:icebr8k/backend/services/user_services/ib_tag_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

import 'create_question_controller.dart';

class CreateQuestionTagPickerController extends GetxController {
  CreateQuestionController createQuestionController;
  TextEditingController textEditingController = TextEditingController();
  CreateQuestionTagPickerController(this.createQuestionController);
  final trendingTags = <IbTag>[].obs;
  final footerText = 'Click to Load More'.obs;
  DocumentSnapshot? lastDoc;

  @override
  Future<void> onInit() async {
    final snapshot = await IbTagDbService().retrieveTrendingIbTags();
    if (snapshot.docs.isNotEmpty) {
      lastDoc = snapshot.docs.last;
    }

    for (final doc in snapshot.docs) {
      trendingTags.add(IbTag.fromJson(doc.data()));
    }

    super.onInit();
  }

  Future<void> addNewTag(String text) async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'));
    createQuestionController.pickedTags
        .add(IbTag(text: text.trim(), creatorId: IbUtils.getCurrentUid()!));
    createQuestionController.pickedTags.value =
        createQuestionController.pickedTags.toSet().toList();
    Get.back();
  }

  Future<void> loadMore() async {
    if (lastDoc != null) {
      final snapshot = await IbTagDbService()
          .retrieveTrendingIbTags(lastDocSnapshot: lastDoc);
      if (snapshot.size == 0) {
        footerText.value = 'No More Tags';
        return;
      }
      lastDoc = snapshot.docs.last;
      for (final doc in snapshot.docs) {
        trendingTags.add(IbTag.fromJson(doc.data()));
      }
    }
  }
}
