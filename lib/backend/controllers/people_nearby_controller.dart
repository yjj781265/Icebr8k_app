import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/ib_local_storage_service.dart';
import 'package:icebr8k/backend/services/ib_location_service.dart';
import 'package:icebr8k/backend/services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:location/location.dart';

class PeopleNearbyController extends GetxController {
  StreamSubscription? locStream;
  final lastRefreshTime = DateTime.now().obs;
  final isGranted = false.obs;
  final shareLoc = false.obs;
  final isSearching = false.obs;
  final items = <PeopleNearbyItem>[].obs;
  LocationData? currentLoc;

  @override
  Future<void> onInit() async {
    shareLoc.value = IbLocalStorageService().isLocSharingOn();
    super.onInit();
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    if (shareLoc.isTrue) {
      await searchPeopleNearby();
    }
  }

  Future<void> searchPeopleNearby() async {
    isGranted.value =
        await IbLocationService().checkPermissionsAndDeviceService();

    if (isGranted.isTrue) {
      lastRefreshTime.value = DateTime.now();

      if (locStream != null) {
        locStream!.cancel();
        locStream = null;
      }

      currentLoc = await IbLocationService().queryLocation();
      await IbLocationService().uploadLocation(currentLoc!);
      final pplNearbyStream =
          IbLocationService().listenToPeopleNearbyChanges(currentLoc!);

      if (pplNearbyStream != null && locStream == null) {
        locStream = pplNearbyStream.listen((list) async {
          await handleGeoPointList(list);
        });
      }
      isSearching.value = false;
    }
  }

  Future<void> removeMyLoc() async {
    await IbLocationService().removeLocation();
  }

  Future<void> handleGeoPointList(
      List<DocumentSnapshot<Map<String, dynamic>>> documentList) async {
    if (currentLoc == null) {
      return;
    }

    if (documentList.isEmpty) {
      items.clear();
      return;
    }

    final List<PeopleNearbyItem> tempList = [];

    for (final doc in documentList) {
      final String uid = doc.data()!['uid'] as String;

      if (documentList.length == 1 && uid == IbUtils.getCurrentUid()) {
        items.clear();
        break;
      }

      if (uid == IbUtils.getCurrentUid()) {
        continue;
      }

      final Map position = doc.data()!['position'] as Map;
      final GeoPoint geoPoint = position['geopoint'] as GeoPoint;
      final double distance =
          calculateDistance(geoPoint.latitude, geoPoint.longitude);
      final user = await IbUserDbService().queryIbUser(uid);
      final compScore = await IbUtils.getCompScore(uid);
      if (user != null) {
        final item = PeopleNearbyItem(
            ibUser: user, distance: distance, compScore: compScore);
        tempList.add(item);
        final index = items.indexOf(item);
        if (index == -1) {
          items.add(item);
        } else {
          items[index] = item;
        }
      }
    }
    items.removeWhere((element) => !tempList.contains(element));
    items.value = items.toSet().toList();
    items.sort((a, b) => b.compScore.compareTo(a.compScore));
  }

  double calculateDistance(double lat, double lng) {
    final point = Geoflutterfire().point(
        latitude: currentLoc!.latitude!, longitude: currentLoc!.longitude!);
    return point.distance(lat: lat, lng: lng);
  }

  @override
  void onClose() {
    if (locStream != null) {
      locStream!.cancel();
    }
    super.onClose();
  }
}

class PeopleNearbyItem {
  IbUser ibUser;
  double distance;
  double compScore;

  PeopleNearbyItem(
      {required this.ibUser, required this.distance, required this.compScore});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeopleNearbyItem &&
          runtimeType == other.runtimeType &&
          ibUser.id == other.ibUser.id;

  @override
  int get hashCode => ibUser.hashCode;
}
