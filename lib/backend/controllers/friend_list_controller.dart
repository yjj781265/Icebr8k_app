import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/auth_controller.dart';
import 'package:icebr8k/backend/models/ib_friend.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_question_db_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

/// controller for current user's friend list in social tab
class FriendListController extends GetxController {
  final friendItems = <FriendListItem>[].obs;
  late StreamSubscription _friendListSub;
  late StreamSubscription _myAnsweredQuestionsSub;

  @override
  void onInit() {
    final String myUid = Get.find<AuthController>().firebaseUser!.uid;
    _friendListSub =
        IbUserDbService().listenToFriendList(myUid).listen((event) async {
      print('found ${event.docChanges.length} friends');
      for (final change in event.docChanges) {
        final IbFriend friend = IbFriend.fromJson(change.doc.data()!);
        final IbUser? ibUser =
            await IbUserDbService().queryIbUser(friend.friendUid);
        if (ibUser == null) {
          continue;
        }
        final double score = await IbUtils.getCompScore(friend.friendUid);
        final FriendListItem item = FriendListItem(
            username: ibUser.username,
            avatarUrl: ibUser.avatarUrl,
            uid: friend.friendUid,
            score: score);
        if (change.type == DocumentChangeType.added) {
          friendItems.addIf(!friendItems.contains(item), item);
          print('added');
        }

        if (change.type == DocumentChangeType.modified) {
          print('modified');
          if (!friendItems.contains(item)) {
            continue;
          }
          friendItems[friendItems.indexOf(item)] = item;
        }

        if (change.type == DocumentChangeType.removed) {
          print('removed');
          friendItems.remove(item);
        }
      }
      friendItems.sort((a, b) => b.score.compareTo(a.score));
    });

    _myAnsweredQuestionsSub = IbQuestionDbService()
        .listenToAnsweredQuestionsChange(myUid)
        .listen((event) {
      _refreshScore();
    });

    super.onInit();
  }

  @override
  void onClose() {
    _friendListSub.cancel();
    _myAnsweredQuestionsSub.cancel();
    super.onClose();
  }

  Future<void> refreshEverything() async {
    print('FriendListController: refreshEverything');
    final String myUid = Get.find<AuthController>().firebaseUser!.uid;
    final _snapshot = await IbUserDbService().queryFriendList(myUid);
    for (final doc in _snapshot.docs) {
      final IbFriend friend = IbFriend.fromJson(doc.data());
      final IbUser? ibUser =
          await IbUserDbService().queryIbUser(friend.friendUid);
      if (ibUser == null) {
        continue;
      }
      final double score = await IbUtils.getCompScore(friend.friendUid);
      final FriendListItem item = FriendListItem(
          username: ibUser.username,
          avatarUrl: ibUser.avatarUrl,
          uid: friend.friendUid,
          score: score);

      if (friendItems.contains(item)) {
        friendItems[friendItems.indexOf(item)] = item;
      } else {
        friendItems.add(item);
      }
    }
    friendItems.sort((a, b) => b.score.compareTo(a.score));
  }

  bool isFriendExist(String uid) {
    for (final item in friendItems) {
      if (item.uid == uid) {
        return true;
      }
    }
    return false;
  }

  Future<void> _refreshScore() async {
    final String myUid = Get.find<AuthController>().firebaseUser!.uid;
    for (final FriendListItem item in friendItems) {
      final double score = await IbUtils.getCompScore(item.uid);
      item.score = score;
    }
    friendItems.sort((a, b) => b.score.compareTo(a.score));
  }
}

class FriendListItem {
  String username;
  String avatarUrl;
  String uid;
  double score;

  FriendListItem(
      {required this.username,
      required this.avatarUrl,
      required this.uid,
      required this.score});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FriendListItem &&
          runtimeType == other.runtimeType &&
          uid == other.uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'FriendListItem{username: $username, avatarUrl: $avatarUrl, uid: $uid, score: $score}';
  }
}
