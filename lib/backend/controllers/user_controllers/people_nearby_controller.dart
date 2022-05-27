import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/managers/Ib_analytics_manager.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_typesense_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_pages/edit_profile_pages/edit_profile_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';

class PeopleNearbyController extends GetxController {
  CarouselController carouselController = CarouselController();
  final rangeInMi = 50.0.obs;
  final genderSelections = [true, true, true].obs;
  final intentionSelection = [true, true].obs;
  final currentIndex = 0.obs;
  final rangeValue = const RangeValues(13, 60).obs;
  final int perPage = 16;
  int page = 1;
  bool hasMore = false;
  Position? currentPosition;
  final items = <NearbyItem>[].obs;
  int loadedCount = 0;
  final isLoading = false.obs;

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
        final nearbyItem = NearbyItem(
            user: user,
            distanceInMeter: distanceInMeter,
            compScore: compScore,
            commonTags: commonTags.toList());
        items.add(nearbyItem);
      }
      hasMore = found > loadedCount;
      items.sort((a, b) => b.compScore.compareTo(a.compScore));
      print(hasMore);
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
      IbUtils.showSimpleSnackBar(
          msg: 'Looking for more people nearby...',
          backgroundColor: IbColors.primaryColor);
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
        final nearbyItem = NearbyItem(
            user: user,
            distanceInMeter: distanceInMeter,
            compScore: compScore,
            commonTags: commonTags.toList());
        tempList.add(nearbyItem);
      }
      hasMore = found > loadedCount;
      tempList.sort((a, b) => b.compScore.compareTo(a.compScore));
      items.addAll(tempList);
    }
  }

  Future<void> clearLocation() async {
    await IbUserDbService().clearLocation();
  }

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
    Get.dialog(IbDialog(
      title: 'Welcome',
      subtitle:
          'Your people nearby profile only visible to others for 7 days, unless you revisit this page to reset the timer ⌛.',
      showNegativeBtn: false,
      onPositiveTap: () async {
        Get.back();
        await _determinePosition();
      },
    ));
  }
}

class NearbyItem {
  final IbUser user;
  final int distanceInMeter;
  final double compScore;
  final List<String> commonTags;

  NearbyItem(
      {required this.user,
      required this.distanceInMeter,
      required this.compScore,
      this.commonTags = const []});

  @override
  String toString() {
    return 'NearbyItem{user: $user, distanceInMeter: $distanceInMeter, '
        'compScore: $compScore, commonTags: $commonTags}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearbyItem &&
          runtimeType == other.runtimeType &&
          user == other.user &&
          distanceInMeter == other.distanceInMeter &&
          compScore == other.compScore &&
          commonTags == other.commonTags;

  @override
  int get hashCode =>
      user.hashCode ^
      distanceInMeter.hashCode ^
      compScore.hashCode ^
      commonTags.hashCode;
}
