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
    if (rxIbUser.value.isPrivate) {
      selectedPrivacy.value = privacyItems[1];
    } else if (!rxIbUser.value.isPrivate && rxIbUser.value.isFriendsOnly) {
      selectedPrivacy.value = privacyItems[2];
    } else {
      selectedPrivacy.value = privacyItems[0];
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
  }

  void onPrivacySelect(String text) {
    if (text == privacyItems[0]) {
      rxIbUser.value.isPrivate = false;
      rxIbUser.value.isFriendsOnly = false;
    } else if (text == privacyItems[1]) {
      rxIbUser.value.isPrivate = true;
      rxIbUser.value.isFriendsOnly = false;
    } else if (text == privacyItems[2]) {
      rxIbUser.value.isPrivate = false;
      rxIbUser.value.isFriendsOnly = true;
    } else {
      rxIbUser.value.isPrivate = false;
      rxIbUser.value.isFriendsOnly = false;
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
      Get.back();
      Get.dialog(const IbDialog(
        title: 'Error',
        subtitle: "Username is taken, try a different username",
        showNegativeBtn: false,
        positiveTextKey: 'ok',
      ));
      return;
    }
    try {
      Get.dialog(const IbLoadingDialog(messageTrKey: 'updating...'),
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

  /*Future<void> validateUsername() async {
    final bool isValid =
        GetUtils.isUsername(username.value.trim().toLowerCase());
    isUsernameFirstTime.value = false;

    if (username.value.isEmpty) {
      usernameErrorTrKey.value = 'username is empty';
      isUsernameValid.value = false;
      return;
    }

    if (username.value.length < IbConfig.kUsernameMinLength) {
      usernameErrorTrKey.value = '3_characters_error';
      isUsernameValid.value = false;
      return;
    }

    if (!isValid) {
      usernameErrorTrKey.value = "username_not_valid";
      isUsernameValid.value = false;
      return;
    }

    if (await IbUserDbService().isUsernameTaken(username.value)) {
      usernameErrorTrKey.value = 'username_exist_error';
      isUsernameValid.value = false;
      return;
    }

    usernameErrorTrKey.value = '';
    isUsernameValid.value = true;
    return;
  }

  Future<void> updateAvatarUrl(String _filePath) async {
    //delete the old one first
    if (IbUtils.getCurrentIbUser() != null &&
        IbUtils.getCurrentIbUser()!.avatarUrl.isNotEmpty) {
      await IbStorageService()
          .deleteFile(IbUtils.getCurrentIbUser()!.avatarUrl);
    }

    final String? photoUrl =
        await IbStorageService().uploadAndRetrieveImgUrl(filePath: _filePath);

    if (photoUrl == null) {
      return;
    }

    await IbUserDbService()
        .updateAvatarUrl(url: photoUrl, uid: IbUtils.getCurrentUid()!);
  }

  Future<void> updateUserInfo(IbUser ibUser) async {
    await validateUsername();
    if (isUsernameValid.isFalse) {
      Get.dialog(IbDialog(
        title: 'Error',
        subtitle: '$usernameErrorTrKey'.tr,
        positiveTextKey: 'ok',
      ));
      return;
    }

    Get.dialog(const IbLoadingDialog(
      messageTrKey: 'updating',
    ));
    await IbUserDbService().updateIbUser(ibUser);
    if (isProfilePicPicked.isTrue) {
      await updateAvatarUrl(avatarUrl.value);
    }

    Get.back(closeOverlays: true);
    IbUtils.showSimpleSnackBar(
        msg: 'Profile updated successfully',
        backgroundColor: IbColors.accentColor);
  }*/
}
