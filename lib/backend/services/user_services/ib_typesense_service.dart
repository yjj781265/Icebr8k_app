import 'dart:convert';

import 'package:get/get.dart';
import 'package:icebr8k/backend/db_config.dart';
import 'package:icebr8k/backend/managers/ib_api_keys_manager.dart';
import 'package:icebr8k/backend/models/ib_tag.dart';

import '../../models/ib_chat_models/ib_chat.dart';

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

  Future<List<String>> searchIbQuestions(String text) async {
    List<String> questionIds = [];
    final String url =
        'https://$_kHost/collections/IbQuestions${DbConfig.dbSuffix}/documents'
        '/search?q=$text&query_by=question&filter_by=isPublic:=true&x-typesense-api-key=$_kApiKey';
    final response = await get(url);

    if (response.isOk && response.bodyString != null) {
      final myMap = jsonDecode(response.bodyString!);
      final docList = myMap['hits'] as List<dynamic>;
      print(docList);
      questionIds = docList.map((e) => e['document']['id'].toString()).toList();
    }

    return questionIds;
  }

  Future<List<String>> searchIbUsers(String text) async {
    List<String> userIds = [];
    final String url =
        'https://$_kHost/collections/IbUsers${DbConfig.dbSuffix}/documents'
        '/search?q=$text&query_by=username,fName&x-typesense-api-key=$_kApiKey';
    final response = await get(url);

    if (response.isOk && response.bodyString != null) {
      final myMap = jsonDecode(response.bodyString!);
      final docList = myMap['hits'] as List<dynamic>;
      userIds = docList.map((e) => e['document']['id'].toString()).toList();
    }

    return userIds;
  }

  Future<List<IbChat>> searchIbCircles(String text) async {
    List<IbChat> ibCircles = [];
    final String url =
        'https://$_kHost/collections/IbChats${DbConfig.dbSuffix}/documents'
        '/search?q=$text&query_by=name&filter_by=isCircle:=true&x-typesense-api-key=$_kApiKey';
    final response = await get(url);
    if (response.isOk && response.bodyString != null) {
      final myMap = jsonDecode(response.bodyString!);
      final docList = myMap['hits'] as List<dynamic>;
      ibCircles = docList
          .map((e) => IbChat.fromJson(e['document'] as Map<String, dynamic>))
          .toList();
    }

    return ibCircles;
  }
}
