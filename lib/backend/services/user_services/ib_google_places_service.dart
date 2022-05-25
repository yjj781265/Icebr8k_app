class IbGooglePlacesService {
  static final IbGooglePlacesService instance = IbGooglePlacesService._();

  factory IbGooglePlacesService() => instance;

  IbGooglePlacesService._();

  /// Todo beta 3.0 feature
  Future<void> queryNearbyPlaces(
      {required double lat,
      required double lng,
      required String apiKey}) async {}
}
