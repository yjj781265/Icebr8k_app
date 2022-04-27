import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/bindings/home_binding.dart';
import 'package:icebr8k/backend/controllers/user_controllers/setup_controller.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/models/icebreaker_models/ib_collection.dart';
import 'package:icebr8k/backend/services/admin_services/ib_admin_db_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/main_page.dart';
import 'package:icebr8k/frontend/ib_pages/review_page.dart';
import 'package:icebr8k/frontend/ib_pages/setup_pages/setup_page_one.dart';
import 'package:icebr8k/frontend/ib_pages/welcome_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_loading_dialog.dart';

class AdminMainController extends GetxController {
  late StreamSubscription applicationSub;
  late StreamSubscription ibCollectionsSub;
  final pendingUsers = <IbUser>[].obs;
  final ibCollections = <IbCollection>[].obs;
  final totalMessages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    applicationSub = IbAdminDbService()
        .listenToPendingApplications()
        .listen((event) => _handlePendingApplicationSnapshot(event));

    ibCollectionsSub = IbAdminDbService()
        .listenToIcebreakerCollection()
        .listen((event) => _handleIbCollectionSnapshot(event));
  }

  @override
  Future<void> dispose() async {
    await applicationSub.cancel();
    await ibCollectionsSub.cancel();
    super.dispose();
  }

  void _handlePendingApplicationSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (final docChange in snapshot.docChanges) {
      if (docChange.doc.data() == null) {
        print('AdminMainController not a valid user');
        continue;
      }

      final IbUser ibUser = IbUser.fromJson(docChange.doc.data()!);
      if (docChange.type == DocumentChangeType.added) {
        pendingUsers.addIf(
            pendingUsers.firstWhereOrNull(
                        (element) => element.id == ibUser.id) ==
                    null &&
                ibUser.status == IbUser.kUserStatusPending,
            ibUser);
        print('AdminMainController added');
        pendingUsers.refresh();
        totalMessages.value++;
      } else if (docChange.type == DocumentChangeType.modified) {
        if (pendingUsers.indexWhere((element) => ibUser.id == element.id) !=
            -1) {
          print('AdminMainController updated');
          pendingUsers[pendingUsers
              .indexWhere((element) => ibUser.id == element.id)] = ibUser;
          pendingUsers.refresh();
        }
      } else {
        print('AdminMainController removed');
        pendingUsers.removeWhere((element) => element.id == ibUser.id);
        pendingUsers.refresh();
        totalMessages.value--;
      }
    }
  }

  void _handleIbCollectionSnapshot(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    for (final docChange in snapshot.docChanges) {
      if (docChange.doc.data() == null) {
        print('AdminMainController not a valid IbCollection');
        continue;
      }

      final IbCollection collection =
          IbCollection.fromJson(docChange.doc.data()!);
      if (docChange.type == DocumentChangeType.added) {
        ibCollections.add(collection);
      } else if (docChange.type == DocumentChangeType.modified) {
        final index =
            ibCollections.indexWhere((element) => element.id == collection.id);
        if (index != -1) {
          ibCollections[index] = collection;
        }
      } else {
        final index =
            ibCollections.indexWhere((element) => element.id == collection.id);
        if (index != -1) {
          ibCollections.removeAt(index);
        }
      }
    }
    ibCollections.refresh();
  }

  Future<void> onUserRoleTap() async {
    Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'));
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      if (IbUtils.getCurrentFbUser() != null &&
          IbUtils.getCurrentFbUser()!.emailVerified) {
        final IbUser? ibUser = await IbUserDbService()
            .queryIbUser(IbUtils.getCurrentFbUser()!.uid);
        String? status = '';
        if (ibUser == null) {
          status = null;
        } else {
          status = ibUser.status;
        }

        switch (status) {
          case IbUser.kUserStatusApproved:
            Get.offAll(() => MainPage(),
                binding: HomeBinding(ibUser!), transition: Transition.fadeIn);
            break;

          case IbUser.kUserStatusBanned:
            //Todo Go to CounterDown Page
            print('Go to CounterDown Page');
            break;

          case IbUser.kUserStatusPending:
            print('Go to InReview Page');
            Get.offAll(() => ReviewPage(),
                transition: Transition.circularReveal);
            break;

          case IbUser.kUserStatusRejected:
            print('Go to Setup page with note');
            Get.offAll(
                () => SetupPageOne(
                      Get.put(
                        SetupController(status: IbUser.kUserStatusRejected),
                      ),
                    ),
                transition: Transition.circularReveal);
            break;
          case null:
            print('Go to Setup page');
            Get.offAll(() => SetupPageOne(Get.put(SetupController())),
                transition: Transition.circularReveal);
            break;

          default:
            print('default Go to Setup page');
            Get.offAll(() => SetupPageOne(Get.put(SetupController())),
                transition: Transition.circularReveal);
            break;
        }
      } else {
        print('AuthController firebase user email is not verified ');
        Get.offAll(() => WelcomePage(),
            transition: Transition.circularReveal,
            duration: const Duration(
                milliseconds: IbConfig.kEventTriggerDelayInMillis));
      }
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.message ?? '',
        positiveTextKey: 'ok',
      ));
    } catch (e) {
      Get.back();
      Get.dialog(IbDialog(
        showNegativeBtn: false,
        onPositiveTap: () => Get.back(),
        title: 'OOPS!',
        subtitle: e.toString(),
        positiveTextKey: 'ok',
      ));
    }
  }

  Future<void> approveApplication(IbUser user) async {
    try {
      await IbAdminDbService()
          .updateUserStatus(status: IbUser.kUserStatusApproved, uid: user.id);
      await IbAdminDbService().sendStatusEmail(
          email: user.email,
          fName: user.fName,
          status: IbUser.kUserStatusApproved);
      Get.back();
      IbUtils.showSimpleSnackBar(
          msg: 'Profile Approved!', backgroundColor: IbColors.accentColor);
    } catch (e) {
      Get.dialog(IbDialog(
        title: 'Oops',
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
  }

  Future<void> rejectApplication(IbUser user) async {
    final TextEditingController editingController = TextEditingController();
    try {
      Get.bottomSheet(
        IbDialog(
          title: 'Info',
          subtitle: "Reasons to reject this profile",
          content: TextField(
            maxLengthEnforcement: MaxLengthEnforcement.none,
            maxLines: 5,
            maxLength: 150,
            keyboardType: TextInputType.text,
            controller: editingController,
          ),
          onPositiveTap: () async {
            if (editingController.text.trim().isEmpty) {
              return;
            }
            Get.back();
            Get.dialog(const IbLoadingDialog(messageTrKey: 'loading'));
            await IbAdminDbService().updateUserStatus(
                status: IbUser.kUserStatusRejected,
                uid: user.id,
                note: editingController.text.trim());
            await IbAdminDbService().sendStatusEmail(
                email: user.email,
                fName: user.fName,
                note: editingController.text.trim(),
                status: IbUser.kUserStatusRejected);
            await IbAdminDbService().deleteAllEmoPics(user);
            await IbAdminDbService().deleteAvatarUrl(user);
            Get.back();
            Get.back();
            IbUtils.showSimpleSnackBar(
                msg: 'Profile rejected!', backgroundColor: IbColors.errorRed);
          },
        ),
      );
    } catch (e) {
      Get.dialog(IbDialog(
        title: 'Oops',
        subtitle: e.toString(),
        showNegativeBtn: false,
      ));
    }
  }
}
