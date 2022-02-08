import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/admin_services/ib_admin_db_service.dart';

class AdminMainController extends GetxController {
  late StreamSubscription applicationSub;
  final pendingUsers = <IbUser>[].obs;
  final totalMessages = 0.obs;

  @override
  void onInit() {
    super.onInit();
    applicationSub = IbAdminService()
        .listenToPendingApplications()
        .listen((event) => _handlePendingApplicationSnapshot(event));
  }

  @override
  Future<void> dispose() async {
    await applicationSub.cancel();
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
            !pendingUsers.contains(ibUser) &&
                ibUser.status == IbUser.kUserStatusPending,
            ibUser);
        pendingUsers.refresh();
        totalMessages.value++;
      } else if (docChange.type == DocumentChangeType.modified) {
        if (pendingUsers.contains(ibUser)) {
          pendingUsers[pendingUsers.indexOf(ibUser)] = ibUser;
          pendingUsers.refresh();
        }
      } else {
        if (pendingUsers.contains(ibUser)) {
          pendingUsers.remove(ibUser);
          pendingUsers.refresh();
          totalMessages.value--;
        }
      }
    }
  }
}
