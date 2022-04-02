class IbLocationService {
  static final IbLocationService _ibLocationService =
      IbLocationService._internal();
  //TODO
  /* static const String _kDbCollection = 'IbUsers${DbConfig.dbSuffix}';
  static const String _kDbLocCollectionGroup = 'Location${DbConfig.dbSuffix}';

  // Init firestore and geoFlutterFire
  final geo = Geoflutterfire();
  final _firestore = FirebaseFirestore.instance;*/

  factory IbLocationService() => _ibLocationService;
  IbLocationService._internal();
}
