import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:location/location.dart';

class IbLocationService {
  static final IbLocationService _ibLocationService =
      IbLocationService._internal();
  final Location _location = Location();

  // Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;

  factory IbLocationService() => _ibLocationService;
  IbLocationService._internal();
  Stream<LocationData> listenToLocChange() {
    return _location.onLocationChanged;
  }

  Future<LocationData> queryLocation() {
    return _location.getLocation();
  }

  Future<void> uploadLocation(LocationData locationData) async {
    if (locationData.latitude == null || locationData.longitude == null) {
      print('locationData is null');
      return;
    }

    final GeoFirePoint loc = geo.point(
        latitude: locationData.latitude!, longitude: locationData.longitude!);
    _firestore
        .collection('IbUsers')
        .doc(IbUtils.getCurrentUid())
        .collection('Location')
        .doc(IbUtils.getCurrentUid())
        .set({
      'uid': IbUtils.getCurrentUid(),
      'position': loc.data,
      'timestampInMs': DateTime.now().millisecondsSinceEpoch
    }, SetOptions(merge: true));
  }

  Future<void> removeLocation() {
    return _firestore
        .collection('IbUsers')
        .doc(IbUtils.getCurrentUid())
        .collection('Location')
        .doc(IbUtils.getCurrentUid())
        .delete();
  }

  Stream<List<DocumentSnapshot<Map<String, dynamic>>>>?
      listenToPeopleNearbyChanges(LocationData centerLoc) {
    if (centerLoc.latitude == null || centerLoc.longitude == null) {
      print('locationData is null');
      return null;
    }

    final GeoFirePoint loc = geo.point(
        latitude: centerLoc.latitude!, longitude: centerLoc.longitude!);
    final collectionRef = _firestore.collectionGroup('Location');

    return geo
        .collection(collectionRef: collectionRef)
        .within(center: loc, radius: 50, field: 'position');
  }

  Future<bool> checkPermissionsAndDeviceService() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) {
        return false;
      }
    }

    print('checkPermissionsAndDeviceService _serviceEnabled $_serviceEnabled');

    _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return false;
      }
    }

    _location.changeSettings(interval: 60000, distanceFilter: 8);
    print(
        'checkPermissionsAndDeviceService _permissionGranted $_permissionGranted');
    return true;
  }
}
