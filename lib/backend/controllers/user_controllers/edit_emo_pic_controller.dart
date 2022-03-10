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

  Future<void> uploadEmoPic(IbEmoPic emoPic) async {
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
      if (rxEmoPics.contains(emoPic)) {
        final String oldUrl = rxEmoPics[rxEmoPics.indexOf(emoPic)].url;
        if (oldUrl == emoPic.url && emoPic.url.contains('http')) {
          rxEmoPics[rxEmoPics.indexOf(emoPic)] = emoPic;
          print('1');
        } else if (!emoPic.url.contains('http')) {
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
        }

        if (oldUrl.contains('http')) {
          await IbStorageService().deleteFile(oldUrl);
        }
        print('2');
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
          rxEmoPics.add(emoPic);
          rxEmoPics.refresh();
          print('3');
        } else {
          rxEmoPics.add(emoPic);
          rxEmoPics.refresh();
        }
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
