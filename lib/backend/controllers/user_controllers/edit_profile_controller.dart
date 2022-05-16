import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_storage_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

class EditProfileController extends GetxController {
  final Rx<IbUser> rxIbUser = IbUtils.getCurrentIbUser()!.obs;
  final coverPhotoUrl = ''.obs;
  final avatarUrl = ''.obs;
  final bio = ''.obs;
  final username = ''.obs;
  final fName = ''.obs;
  final lName = ''.obs;
  final gender = ''.obs;
  final genderSelections = [false, false, false].obs;
  final selectedPrivacy = ''.obs;
  final List<String> privacyItems = [
    'public'.tr,
    'private'.tr,
    'friends_only'.tr,
  ];
  final RxInt birthdateInMs = 0.obs;
  final TextEditingController birthdateTeController = TextEditingController();
  final TextEditingController fNameTeController = TextEditingController();
  final TextEditingController lNameTeController = TextEditingController();
  final TextEditingController usernameTeController = TextEditingController();
  final TextEditingController bioTeController = TextEditingController();

  EditProfileController() {
    coverPhotoUrl.value = rxIbUser.value.coverPhotoUrl;
    avatarUrl.value = rxIbUser.value.avatarUrl;
    fName.value = rxIbUser.value.fName;
    lName.value = rxIbUser.value.lName;
    gender.value = rxIbUser.value.gender;
    username.value = rxIbUser.value.username;
    birthdateInMs.value = rxIbUser.value.birthdateInMs ?? -1;
    bio.value = rxIbUser.value.bio;
    if (IbUser.kGenders.contains(gender.value)) {
      genderSelections[IbUser.kGenders.indexOf(gender.value)] = true;
    }
    if (rxIbUser.value.profilePrivacy == IbUser.kUserPrivacyPublic) {
      selectedPrivacy.value = privacyItems[0];
    } else if (rxIbUser.value.profilePrivacy == IbUser.kUserPrivacyPrivate) {
      selectedPrivacy.value = privacyItems[1];
    } else {
      selectedPrivacy.value = privacyItems[2];
    }
  }

  @override
  void onClose() {
    bioTeController.dispose();
    fNameTeController.dispose();
    lNameTeController.dispose();
    usernameTeController.dispose();
    birthdateTeController.dispose();
    super.onClose();
  }

  void onGenderSelect(int index) {
    for (int i = 0; i < genderSelections.length; i++) {
      if (i == index) {
        continue;
      }
      genderSelections[i] = false;
    }
    genderSelections[index] = !genderSelections[index];
    if (genderSelections[index]) {
      gender.value = IbUser.kGenders[index];
    } else {
      gender.value = '';
    }
    genderSelections.refresh();
  }

  void onPrivacySelect(String text) {
    if (text == privacyItems[0]) {
      rxIbUser.value.profilePrivacy = IbUser.kUserPrivacyPublic;
    } else if (text == privacyItems[1]) {
      rxIbUser.value.profilePrivacy = IbUser.kUserPrivacyPrivate;
    } else if (text == privacyItems[2]) {
      rxIbUser.value.profilePrivacy = IbUser.kUserPrivacyFrOnly;
    } else {
      rxIbUser.value.profilePrivacy = IbUser.kUserPrivacyFrOnly;
    }
  }

  Future<void> validate() async {
    if (fNameTeController.text.trim().isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "First name is empty",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (birthdateTeController.text.trim().isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Birthdate is empty",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (!IbUtils.isOver13(
        DateTime.fromMillisecondsSinceEpoch(birthdateInMs.value))) {
      Get.dialog(const IbDialog(
        title: 'Age limit',
        subtitle: "You must be at least 13 to use Icebr8k",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (gender.value.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Gender is not picked",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }
    if (avatarUrl.isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Avatar is empty",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (usernameTeController.text.trim().length < IbConfig.kUsernameMinLength) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: "Username needs at least 3 characters",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (!GetUtils.isUsername(usernameTeController.text.trim()) ||
        usernameTeController.text.trim().toLowerCase() == 'anonymous') {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: "Username is not valid",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (bioTeController.text.trim().isEmpty) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Bio is empty",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (bioTeController.text.trim().length < 30) {
      Get.dialog(const IbDialog(
        title: 'Missing Info',
        subtitle: "Bio needs to be at least 30 characters long",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }

    if (await IbUserDbService()
            .isUsernameTaken(usernameTeController.text.trim()) &&
        rxIbUser.value.username != usernameTeController.text.trim()) {
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: "Username is taken, try a different username",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }
    try {
      Get.dialog(const IbLoadingDialog(messageTrKey: 'update'),
          barrierDismissible: false);

      /// upload to cloud
      if (avatarUrl.value != rxIbUser.value.avatarUrl &&
          !avatarUrl.contains('http')) {
        // rm the old url
        final String? url = await IbStorageService()
            .uploadAndRetrieveImgUrl(filePath: avatarUrl.value);
        if (url == null) {
          Get.back();
          IbUtils.showSimpleSnackBar(
              msg: 'Failed to upload avatar image',
              backgroundColor: IbColors.errorRed);
          return;
        }
        await IbStorageService().deleteFile(rxIbUser.value.avatarUrl);
        rxIbUser.value.avatarUrl = url;
      }

      if (coverPhotoUrl.value != rxIbUser.value.coverPhotoUrl &&
          !coverPhotoUrl.contains('http')) {
        final String? url = await IbStorageService()
            .uploadAndRetrieveImgUrl(filePath: coverPhotoUrl.value);
        if (url == null) {
          Get.back();
          IbUtils.showSimpleSnackBar(
              msg: 'Failed to upload cover photo',
              backgroundColor: IbColors.errorRed);
          return;
        }
        if (rxIbUser.value.coverPhotoUrl != IbConfig.kDefaultCoverPhotoUrl) {
          // rm the old cover photo url
          await IbStorageService().deleteFile(rxIbUser.value.coverPhotoUrl);
        }
        rxIbUser.value.coverPhotoUrl = url;
      }

      /// update user info
      rxIbUser.value.username = usernameTeController.text.trim().toLowerCase();
      rxIbUser.value.fName = fNameTeController.text.trim();
      rxIbUser.value.lName = lNameTeController.text.trim();
      rxIbUser.value.bio = bioTeController.text.trim();
      rxIbUser.value.gender = gender.value;
      rxIbUser.value.birthdateInMs = birthdateInMs.value;
      await IbUserDbService().updateIbUser(rxIbUser.value);
      Get.back(closeOverlays: true);
      IbUtils.showSimpleSnackBar(
          msg: 'Profile Updated!', backgroundColor: IbColors.accentColor);
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        title: 'Error',
        subtitle: e.toString(),
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
    }
  }
}
