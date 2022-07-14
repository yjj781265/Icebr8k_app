import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/backend/services/user_services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

class EditEmoPicController extends GetxController {
  final RxList<IbEmoPic> rxEmoPics;

  EditEmoPicController(this.rxEmoPics);

  @override
  Future<void> onReady() async {
    super.onReady();
    await IbAnalyticsManager().logScreenView(
        className: 'EditEmoPicController', screenName: 'EditEmoPic');
  }

  Future<void> onRemoveCard(IbEmoPic e) async {
    rxEmoPics.remove(e);
    try {
      Get.dialog(const IbLoadingDialog(messageTrKey: 'update'),
          barrierDismissible: false);
      await IbStorageService().deleteFile(e.url);
      await IbUserDbService()
          .updateEmoPics(emoPics: rxEmoPics, uid: IbUtils().getCurrentUid()!);
    } finally {
      Get.back();
    }
  }

  Future<void> uploadEmoPic(
      {required IbEmoPic emoPic, required String oldUrl}) async {
    if (emoPic.id.isEmpty) {
      return;
    }

    if (emoPic.url.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Photo is missing",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (emoPic.emoji.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Emoji is missing",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (emoPic.description.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Description is missing",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    try {
      Get.dialog(const IbLoadingDialog(messageTrKey: 'upload'),
          barrierDismissible: false);
      final bool shouldUpdateUrl =
          emoPic.url != oldUrl && !emoPic.url.contains('http');

      if (shouldUpdateUrl) {
        final String? newUrl = await IbStorageService().uploadAndRetrieveImgUrl(
            filePath: emoPic.url,
            oldUrl: oldUrl.contains('http') ? oldUrl : '');
        if (newUrl == null) {
          Get.back();
          Get.dialog(const IbDialog(
            title: 'Error',
            subtitle: 'Failed to upload image',
            showNegativeBtn: false,
          ));
          return;
        }
        emoPic.url = newUrl;
      }

      if (rxEmoPics.contains(emoPic)) {
        rxEmoPics[rxEmoPics.indexOf(emoPic)] = emoPic;
      } else {
        rxEmoPics.add(emoPic);
      }

      rxEmoPics.refresh();
      await IbUserDbService()
          .updateEmoPics(emoPics: rxEmoPics, uid: IbUtils().getCurrentUid()!);

      Get.back(closeOverlays: true);

      IbUtils().showSimpleSnackBar(
          msg: 'EmoPic uploaded', backgroundColor: IbColors.accentColor);
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        title: 'Error',
        subtitle: 'Failed to upload image ${e.toString()}',
        showNegativeBtn: false,
      ));
    }
  }
}
