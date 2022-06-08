import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/models/ib_notification.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_local_data_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_typesense_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/edit_profile_pages/edit_profile_page.dart';
import 'package:icebr8k/frontend/ib_pages/people_nearby_pages/bingo_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class PeopleNearbyController extends GetxController {
  RefreshController refreshController = RefreshController();
  RefreshController likeRefreshController = RefreshController();
  final rangeInMi = 50.0.obs;
  final genderSelections = [true, true, true].obs;
  final intentionSelection = [true, true].obs;
  final isExpanded = true.obs;
  final currentIndex = 0.obs;
  final rangeValue = const RangeValues(13, 60).obs;
  final int perPage = 16;
  int page = 1;
  bool hasMore = false;
  Position? currentPosition;
  final likeItems = <LikedItem>[].obs;
  final items = <NearbyItem>[].obs;
  int loadedCount = 0;
  final isLoading = false.obs;
  DocumentSnapshot? lastLikedDoc;

  @override
  Future<void> onReady() async {
    await IbAnalyticsManager().logScreenView(
        className: 'PeopleNearbyController', screenName: 'PeopleNearby');
    intentionSelection.value = [
      IbUtils.getCurrentIbUser()!
          .intentions
          .contains(IbUser.kUserIntentionDating),
      IbUtils.getCurrentIbUser()!
          .intentions
          .contains(IbUser.kUserIntentionFriendship)
    ];
    _loadLocalSearchCriteria();

    Get.dialog(IbDialog(
      title: 'Welcome',
      subtitle: 'Your people nearby profile only visible to others for 7 days, '
          'unless you revisit this page to reset the timer ⌛.',
      showNegativeBtn: false,
      onPositiveTap: () async {
        Get.back();
        await _determinePosition();
      },
    ));
  }

  void _loadLocalSearchCriteria() {
    rangeInMi.value = IbLocalDataService()
        .retrieveIntValue(StorageKey.peopleNearbyRangInMiInt)
        .toDouble();
    if (rangeInMi.value == 0) {
      rangeInMi.value = 50;
    }

    int minAge =
        IbLocalDataService().retrieveIntValue(StorageKey.peopleNearbyMinAgeInt);
    if (minAge == 0) {
      minAge = 13;
    }

    int maxAge =
        IbLocalDataService().retrieveIntValue(StorageKey.peopleNearbyMaxAgeInt);
    if (maxAge == 0) {
      maxAge = 60;
    }
    rangeValue.value = RangeValues(minAge.toDouble(), maxAge.toDouble());
  }

  void _cacheLocalSearchCriteria() {
    IbLocalDataService().updateIntValue(
        key: StorageKey.peopleNearbyRangInMiInt,
        value: rangeInMi.value.toInt());
    IbLocalDataService().updateIntValue(
        key: StorageKey.peopleNearbyMinAgeInt,
        value: rangeValue.value.start.toInt());
    IbLocalDataService().updateIntValue(
        key: StorageKey.peopleNearbyMaxAgeInt,
        value: rangeValue.value.end.toInt());
  }

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> _determinePosition() async {
    final currentUser = IbUtils.getCurrentIbUser();
    if (currentUser == null) {
      print('user is null');
      return;
    }

    if (currentUser.profilePrivacy != IbUser.kUserPrivacyPublic) {
      Get.dialog(
          IbDialog(
            title: 'Change your profile to public',
            subtitle:
                'Only the public profiles will be visible in people nearby feature',
            actionButtons: TextButton(
              onPressed: () {
                Get.back();
                Get.off(() => EditProfilePage());
              },
              child: const Text('Edit My Profile'),
            ),
            showNegativeBtn: false,
          ),
          barrierDismissible: false);
      return;
    }

    bool serviceEnabled;
    LocationPermission permission;
    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      Get.dialog(IbDialog(
        title: 'Location services are disabled',
        subtitle:
            'Please turn on location service in order to see people nearby',
        showNegativeBtn: false,
        actionButtons: TextButton(
          child: const Text('Open Settings'),
          onPressed: () async {
            Get.back();
            await Geolocator.openLocationSettings();
          },
        ),
      ));

      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.dialog(IbDialog(
          title: 'Location permission is needed',
          subtitle: 'Please grant location permission to see people nearby',
          showNegativeBtn: false,
          actionButtons: TextButton(
            child: const Text('Open Settings'),
            onPressed: () async {
              Get.back();
              await Geolocator.openAppSettings();
            },
          ),
        ));
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.dialog(IbDialog(
        title: 'Location permission is needed',
        subtitle: 'Please grant location permission to see people nearby',
        showNegativeBtn: false,
        actionButtons: TextButton(
          child: const Text('Open Settings'),
          onPressed: () async {
            Get.back();
            await Geolocator.openAppSettings();
          },
        ),
      ));
      return;
    }

    loadItem();
  }

  Future<void> loadItem() async {
    final currentUser = IbUtils.getCurrentIbUser();
    loadedCount = 0;
    page = 1;
    refreshController.resetNoData();
    if (currentUser == null) {
      return;
    }
    if (currentUser.profilePrivacy != IbUser.kUserPrivacyPublic) {
      Get.dialog(
          IbDialog(
            title: 'Change your profile to public',
            subtitle:
                'Only the public profiles will be visible in people nearby feature',
            actionButtons: TextButton(
              onPressed: () {
                Get.back();
                Get.off(() => EditProfilePage());
              },
              child: const Text('Edit My Profile'),
            ),
            showNegativeBtn: false,
          ),
          barrierDismissible: false);
      return;
    }
    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    isLoading.value = true;
    currentIndex.value = 0;
    items.clear();
    try {
      currentPosition = await Geolocator.getLastKnownPosition();
      currentPosition ??= await Geolocator.getCurrentPosition(
          timeLimit: const Duration(minutes: 5));
      if (currentPosition == null) {
        throw Exception();
      }

      print(currentPosition);
      await IbUserDbService().updateCurrentUserPosition(
          GeoPoint(currentPosition!.latitude, currentPosition!.longitude));

      final List<String> genders = [];

      for (int i = 0; i < genderSelections.length; i++) {
        if (genderSelections[i]) {
          genders.add(IbUser.kGenders[i]);
        }
      }

      final List<String> intentions = [];

      for (int i = 0; i < intentionSelection.length; i++) {
        if (intentionSelection[i]) {
          intentions.add(IbUser.kIntentions[i]);
        }
      }

      await IbUserDbService().updateUserIntention(intentions);

      final data = await IbTypeSenseService().searchPplNearby(currentPosition!,
          perPage: perPage,
          radiusInMi: rangeInMi.value,
          page: page,
          genders: genders,
          minAge: rangeValue.value.start.toInt(),
          maxAge: rangeValue.value.end.toInt());
      final found = data['found'] as int;
      page = data['page'] as int;
      final docList = data['hits'] as List<dynamic>;
      loadedCount += docList.length;

      for (final item in docList) {
        final String id = item['document']['id'].toString();
        final IbUser? user = await IbUserDbService().queryIbUser(id);
        if (user == null) {
          continue;
        }
        if (user.intentions
            .toSet()
            .intersection(intentions.toSet())
            .toList()
            .isEmpty) {
          continue;
        }
        final int distanceInMeter =
            item['geo_distance_meters']['geoPoint'] as int;
        final commonTags = IbUtils.getCurrentIbUser()!
            .tags
            .toSet()
            .intersection(user.tags.toSet());
        final compScore = await IbUtils.getCompScore(uid: id);
        final liked = await IbUserDbService().isProfileLiked(
            user1Id: IbUtils.getCurrentUid()!, user2Id: user.id);
        final lastLikedTimestampInMs =
            await IbUserDbService().lastLikedTimestampInMs(user.id);
        final nearbyItem = NearbyItem(
            user: user,
            liked: liked,
            lastLikedTimestampInMs: lastLikedTimestampInMs,
            distanceInMeter: distanceInMeter,
            compScore: compScore,
            commonTags: commonTags.toList());
        items.add(nearbyItem);
      }
      _cacheLocalSearchCriteria();
      hasMore = found > loadedCount;
      items.sort((a, b) => a.distanceInMeter.compareTo(b.distanceInMeter));
      isLoading.value = false;
    } catch (e) {
      print(e);
      Get.dialog(
        const IbDialog(
          title: 'Error',
          subtitle: "Oops, something is wrong",
          showNegativeBtn: false,
        ),
      );
      isLoading.value = false;
      hasMore = false;
    }
  }

  Future<void> loadMore() async {
    if (hasMore) {
      page++;
      final List<String> genders = [];

      for (int i = 0; i < genderSelections.length; i++) {
        if (genderSelections[i]) {
          genders.add(IbUser.kGenders[i]);
        }
      }

      final List<String> intentions = [];

      for (int i = 0; i < intentionSelection.length; i++) {
        if (intentionSelection[i]) {
          intentions.add(IbUser.kIntentions[i]);
        }
      }

      final data = await IbTypeSenseService().searchPplNearby(currentPosition!,
          perPage: perPage,
          radiusInMi: rangeInMi.value,
          page: page,
          genders: genders,
          minAge: rangeValue.value.start.toInt(),
          maxAge: rangeValue.value.end.toInt());
      final found = data['found'] as int;
      page = data['page'] as int;
      final docList = data['hits'] as List<dynamic>;
      loadedCount += docList.length;
      final tempList = <NearbyItem>[];
      for (final item in docList) {
        final String id = item['document']['id'].toString();
        final IbUser? user = await IbUserDbService().queryIbUser(id);
        if (user == null) {
          continue;
        }
        if (user.intentions
            .toSet()
            .intersection(intentions.toSet())
            .toList()
            .isEmpty) {
          continue;
        }

        final int distanceInMeter =
            item['geo_distance_meters']['geoPoint'] as int;
        final commonTags = IbUtils.getCurrentIbUser()!
            .tags
            .toSet()
            .intersection(user.tags.toSet());
        final compScore = await IbUtils.getCompScore(uid: id);
        final liked = await IbUserDbService().isProfileLiked(
            user1Id: IbUtils.getCurrentUid()!, user2Id: user.id);
        final lastLikedTimestampInMs =
            await IbUserDbService().lastLikedTimestampInMs(user.id);
        final nearbyItem = NearbyItem(
            liked: liked,
            user: user,
            lastLikedTimestampInMs: lastLikedTimestampInMs,
            distanceInMeter: distanceInMeter,
            compScore: compScore,
            commonTags: commonTags.toList());
        tempList.add(nearbyItem);
      }
      hasMore = found > loadedCount;
      tempList.sort((a, b) => a.distanceInMeter.compareTo(b.distanceInMeter));
      items.addAll(tempList);
      refreshController.loadComplete();
    } else {
      refreshController.loadNoData();
    }
  }

  Future<void> clearLocation() async {
    await IbUserDbService().clearLocation();
  }

  Future<void> likeProfile(NearbyItem item) async {
    if (item.liked) {
      return;
    }

    final likedEndTimestampInMs =
        item.lastLikedTimestampInMs + const Duration(days: 1).inMilliseconds;
    if (item.lastLikedTimestampInMs != -1 &&
        DateTime.now().millisecondsSinceEpoch < likedEndTimestampInMs) {
      IbUtils.showSimpleSnackBar(
          msg: 'You cannot like this profile again until '
              '${IbUtils.readableDateTime(DateTime.fromMillisecondsSinceEpoch(likedEndTimestampInMs), showTime: true)}',
          backgroundColor: IbColors.primaryColor);
      return;
    }

    item.liked = true;
    item.lastLikedTimestampInMs = Timestamp.now().millisecondsSinceEpoch;
    items.refresh();

    await IbUserDbService().likeProfile(item.user.id);
    if (!await IbUserDbService()
        .isProfileLikedNotificationSent(recipientId: item.user.id)) {
      await IbUserDbService().sendAlertNotification(IbNotification(
          id: IbUtils.getUniqueId(),
          body: '',
          type: IbNotification.kProfileLiked,
          timestamp: FieldValue.serverTimestamp(),
          senderId: IbUtils.getCurrentUid()!,
          recipientId: item.user.id));
    }

    if (await IbUserDbService().isProfileBingo(
        user1Id: IbUtils.getCurrentUid()!, user2Id: item.user.id)) {
      await HapticFeedback.mediumImpact();
      Get.to(() => BingoPage(user: item.user),
          fullscreenDialog: true, transition: Transition.zoom);
    }
  }

  Future<void> dislikeProfile(NearbyItem item) async {
    if (!item.liked) {
      return;
    }

    await IbUserDbService().dislikeProfile(item.user.id);
    item.liked = false;
    items.refresh();
  }

  Future<void> loadLikedItems() async {
    likeItems.clear();
    final snapshot = await IbUserDbService().queryProfileLikedUsers();
    for (final doc in snapshot.docs) {
      final likerId = doc.data()['likerId'];
      if (likerId == null) {
        continue;
      }

      final user = await IbUserDbService().queryIbUser(likerId.toString());
      if (user == null) {
        continue;
      }

      final timestamp = doc.data()['timestamp'];
      if (timestamp == null) {
        continue;
      }

      final likedTimestampInMs =
          (timestamp as Timestamp).millisecondsSinceEpoch;
      final isBingo = await IbUserDbService()
          .isProfileBingo(user1Id: IbUtils.getCurrentUid()!, user2Id: user.id);
      final geoPoint = user.geoPoint;

      int? distanceInMeter;
      if (geoPoint != null &&
          currentPosition != null &&
          (geoPoint as GeoPoint).latitude != 0 &&
          geoPoint.longitude != 0) {
        distanceInMeter = Geolocator.distanceBetween(
                currentPosition!.latitude,
                currentPosition!.longitude,
                geoPoint.latitude,
                geoPoint.longitude)
            .toInt();
      }

      likeItems.add(LikedItem(
          user: user,
          distanceInMeters: distanceInMeter,
          isBingo: isBingo,
          likedTimestampInMs: likedTimestampInMs));

      lastLikedDoc = doc;
    }
  }

  Future<void> loadMoreLikedItems() async {
    if (lastLikedDoc == null) {
      likeRefreshController.loadNoData();
      return;
    }

    final snapshot =
        await IbUserDbService().queryProfileLikedUsers(lastDoc: lastLikedDoc);
    for (final doc in snapshot.docs) {
      final likerId = doc.data()['likerId'];
      if (likerId == null) {
        continue;
      }

      final user = await IbUserDbService().queryIbUser(likerId.toString());
      if (user == null) {
        continue;
      }

      final timestamp = doc.data()['timestamp'];
      if (timestamp == null) {
        continue;
      }

      final likedTimestampInMs =
          (timestamp as Timestamp).millisecondsSinceEpoch;
      final isBingo = await IbUserDbService()
          .isProfileBingo(user1Id: IbUtils.getCurrentUid()!, user2Id: user.id);
      final geoPoint = user.geoPoint;
      int? distanceInMeter;
      if (geoPoint != null &&
          currentPosition != null &&
          (geoPoint as GeoPoint).latitude != 0 &&
          geoPoint.longitude != 0) {
        distanceInMeter = Geolocator.distanceBetween(
                currentPosition!.latitude,
                currentPosition!.longitude,
                geoPoint.latitude,
                geoPoint.longitude)
            .toInt();
      }

      likeItems.add(LikedItem(
          distanceInMeters: distanceInMeter,
          user: user,
          isBingo: isBingo,
          likedTimestampInMs: likedTimestampInMs));

      lastLikedDoc = doc;
    }
    if (snapshot.docs.isEmpty) {
      likeRefreshController.loadNoData();
      lastLikedDoc = null;
      return;
    }
    likeRefreshController.loadComplete();
  }
}

class NearbyItem {
  final IbUser user;
  final int distanceInMeter;
  bool liked;
  int lastLikedTimestampInMs;
  final double compScore;
  final List<String> commonTags;

  NearbyItem(
      {required this.user,
      required this.distanceInMeter,
      required this.compScore,
      required this.liked,
      required this.lastLikedTimestampInMs,
      this.commonTags = const []});

  @override
  String toString() {
    return 'NearbyItem{user: $user, distanceInMeter: $distanceInMeter, '
        'liked: $liked, compScore: $compScore, commonTags: $commonTags}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyItem &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          distanceInMeter == other.distanceInMeter &&
          liked == other.liked &&
          lastLikedTimestampInMs == other.lastLikedTimestampInMs &&
          compScore == other.compScore &&
          commonTags == other.commonTags;

  @override
  int get hashCode =>
      user.hashCode ^
      distanceInMeter.hashCode ^
      liked.hashCode ^
      lastLikedTimestampInMs.hashCode ^
      compScore.hashCode ^
      commonTags.hashCode;
}

class LikedItem {
  final IbUser user;
  final bool isBingo;
  final int likedTimestampInMs;
  final int? distanceInMeters;

  LikedItem(
      {required this.user,
      required this.isBingo,
      this.distanceInMeters,
      required this.likedTimestampInMs});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LikedItem &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          isBingo == other.isBingo &&
          likedTimestampInMs == other.likedTimestampInMs;

  @override
  int get hashCode =>
      user.hashCode ^ isBingo.hashCode ^ likedTimestampInMs.hashCode;
}
