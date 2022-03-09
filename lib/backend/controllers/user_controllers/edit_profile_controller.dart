import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';

class EditProfileController extends GetxController {
  final Rx<IbUser> rxIbUser;
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

  EditProfileController(this.rxIbUser) {
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
