import 'dart:convert';

import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_gif.dart';

class IbTenorService extends GetConnect {
  final String kApiKey = 'YGXPQ2ECHA8Q';

  Future<List<IbGif>> searchGif(
      {required String searchText, String? next}) async {
    late Response response;
    final List<IbGif> ibGifs = [];
    if (next != null) {
      response = await post(
          'https://g.tenor.com/v1/search?q=$searchText&key=$kApiKey&media_filter=minimal&pos=$next',
          '');
    } else {
      response = await post(
          'https://g.tenor.com/v1/search?q=$searchText&key=$kApiKey&media_filter=minimal',
          '');
    }

    if (response.isOk && response.bodyString != null) {
      final myMap = jsonDecode(response.bodyString!);
      final next = myMap['next'].toString();
      final List<dynamic> tempList = myMap['results'] as List;
      for (final item in tempList) {
        final String id = item['id'].toString();
        final String description = item['content_description'].toString();
        final url = item['media'][0]['tinygif']['url'].toString();
        final int width = item['media'][0]['tinygif']['dims'][0] as int;
        final int height = item['media'][0]['tinygif']['dims'][1] as int;
        final double timeStampInSec = item['created'] as double;
        final IbGif ibGif = IbGif(
            url: url,
            width: width,
            height: height,
            id: id,
            next: next,
            timeStampInSec: timeStampInSec,
            description: description);
        ibGifs.add(ibGif);
      }
    }

    return ibGifs;
  }

  Future<List<IbGif>> getTrendingGifs({String? next}) async {
    late Response response;
    final List<IbGif> ibGifs = [];
    if (next != null) {
      response = await post(
          'https://g.tenor.com/v1/trending?key=$kApiKey&media_filter=minimal&pos=$next',
          '');
    } else {
      response = await post(
          'https://g.tenor.com/v1/trending?key=$kApiKey&media_filter=minimal',
          '');
    }

    if (response.isOk && response.bodyString != null) {
      final myMap = jsonDecode(response.bodyString!);
      final next = myMap['next'].toString();
      final List<dynamic> tempList = myMap['results'] as List;
      for (final item in tempList) {
        final String id = item['id'].toString();
        final String description = item['content_description'].toString();
        final url = item['media'][0]['tinygif']['url'].toString();
        final int width = item['media'][0]['tinygif']['dims'][0] as int;
        final int height = item['media'][0]['tinygif']['dims'][1] as int;
        final double timeStampInSec = item['created'] as double;
        final IbGif ibGif = IbGif(
            url: url,
            width: width,
            height: height,
            id: id,
            next: next,
            timeStampInSec: timeStampInSec,
            description: description);
        ibGifs.add(ibGif);
      }
    }

    return ibGifs;
  }

  Future<List<String>> getTrendingTerms() async {
    late Response response;
    final List<String> terms = [];
    response =
        await post('https://g.tenor.com/v1/trending_terms?key=$kApiKey', '');

    if (response.isOk && response.bodyString != null) {
      final myMap = jsonDecode(response.bodyString!);
      final List<dynamic> tempList = myMap['results'] as List;

      for (final item in tempList) {
        terms.add(item.toString());
      }
    }

    return terms;
  }

  Future<List<String>> getAutocomplete(String text) async {
    late Response response;
    final List<String> terms = [];
    response = await post(
        'https://g.tenor.com/v1/autocomplete?q=$text&key=$kApiKey', '');

    if (response.isOk && response.bodyString != null) {
      final myMap = jsonDecode(response.bodyString!);
      final List<dynamic> tempList = myMap['results'] as List;

      for (final item in tempList) {
        terms.add(item.toString());
      }
    }
    return terms;
  }
}
