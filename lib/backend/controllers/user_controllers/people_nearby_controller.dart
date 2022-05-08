import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_user.dart';
import 'package:icebr8k/backend/services/user_services/ib_typesense_service.dart';
import 'package:icebr8k/backend/services/user_services/ib_user_db_service.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';

class PeopleNearbyController extends GetxController {
  CarouselController carouselController = CarouselController();

  /// Determine the current position of the device.
  ///
  /// When the location services are not enabled or permissions
  /// are denied the `Future` will return an error.
  Future<void> _determinePosition() async {
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

      return Future.error('Location services are disabled.');
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
        return Future.error('Location permissions are denied');
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
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    final location = await Geolocator.getCurrentPosition();
    await IbUserDbService().updateCurrentUserPosition(
        GeoPoint(location.latitude, location.longitude));
    final list = await IbTypeSenseService().searchPplNearby(location);
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    await _determinePosition();
  }

  @override
  void onClose() {}

  @override
  void onReady() {}
}

class NearbyItem {
  final IbUser user;
  final double distance;
  final double compScore;

  NearbyItem(
      {required this.user, required this.distance, required this.compScore});
}
