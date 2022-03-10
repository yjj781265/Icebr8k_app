import 'package:get/get.dart';
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

  Future<void> onRemoveCard(IbEmoPic e) async {
    rxEmoPics.remove(e);
    try {
      Get.dialog(const IbLoadingDialog(messageTrKey: 'update'),
          barrierDismissible: false);
      await IbStorageService().deleteFile(e.url);
      await IbUserDbService()
          .updateEmoPics(emoPics: rxEmoPics, uid: IbUtils.getCurrentUid()!);
    } finally {
      Get.back();
    }
  }

  Future<void> uploadEmoPic(IbEmoPic emoPic) async {
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

      /// check the old and new url are not the same
      if (rxEmoPics.contains(emoPic) &&
          rxEmoPics[rxEmoPics.indexOf(emoPic)].url != emoPic.url) {
        if (!emoPic.url.contains('http')) {
          final String? newUrl = await IbStorageService()
              .uploadAndRetrieveImgUrl(filePath: emoPic.url);
          if (newUrl == null) {
            Get.back();
            IbUtils.showSimpleSnackBar(
                msg: 'Failed to upload image',
                backgroundColor: IbColors.errorRed);
            return;
          }
          if (rxEmoPics[rxEmoPics.indexOf(emoPic)].url.contains('http')) {
            await IbStorageService()
                .deleteFile(rxEmoPics[rxEmoPics.indexOf(emoPic)].url);
          }
          emoPic.url = newUrl;
        }

        rxEmoPics[rxEmoPics.indexOf(emoPic)] = emoPic;
        rxEmoPics.refresh();
      } else {
        if (!emoPic.url.contains('http')) {
          final String? newUrl = await IbStorageService()
              .uploadAndRetrieveImgUrl(filePath: emoPic.url);
          if (newUrl == null) {
            Get.back();
            IbUtils.showSimpleSnackBar(
                msg: 'Failed to upload image',
                backgroundColor: IbColors.errorRed);
            return;
          }
          emoPic.url = newUrl;
          emoPic.id = IbUtils.getUniqueId();
        }
        rxEmoPics.add(emoPic);
        rxEmoPics.refresh();
      }

      await IbUserDbService()
          .updateEmoPics(emoPics: rxEmoPics, uid: IbUtils.getCurrentUid()!);

      Get.back(closeOverlays: true);

      IbUtils.showSimpleSnackBar(
          msg: 'EmoPic uploaded', backgroundColor: IbColors.accentColor);
    } catch (e) {
      IbUtils.showSimpleSnackBar(
          msg: 'Failed to upload image $e', backgroundColor: IbColors.errorRed);
    }
  }
}
