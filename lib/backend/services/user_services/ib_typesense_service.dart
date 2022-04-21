import 'dart:convert';

import 'package:get/get.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/managers/ib_api_keys_manager.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';

class IbTypeSenseService extends GetConnect {
  static final IbTypeSenseService _ibTypeSense = IbTypeSenseService._();

  late String _kApiKey;
  late String _kHost;
  factory IbTypeSenseService() => _ibTypeSense;
  IbTypeSenseService._() {
    _kApiKey = IbApiKeysManager.kTypeSenseSearchApiKey;
    _kHost = IbApiKeysManager.kTypeSenseNode;
  }

  Future<List<IbTag>> searchIbTags(String text) async {
    List<IbTag> ibTags = [];
    final String url =
        'https://$_kHost/collections/IbTags${DbConfig.dbSuffix}/documents'
        '/search?q=$text&query_by=text&x-typesense-api-key=$_kApiKey';
    final response = await get(url);

    if (response.isOk && response.bodyString != null) {
      final myMap = jsonDecode(response.bodyString!);
      final docList = myMap['hits'] as List<dynamic>;
      ibTags = docList
          .map((e) => IbTag.fromJson(e['document'] as Map<String, dynamic>))
          .toList();
    }

    return ibTags;
  }
}
