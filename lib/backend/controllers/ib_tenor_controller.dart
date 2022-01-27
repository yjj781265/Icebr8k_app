import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/models/ib_gif.dart';
import 'package:icebr8k/backend/services/ib_tenor_service.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IbTenorController extends GetxController {
  final trendingGifs = <IbGif>[].obs;
  final resultGifs = <IbGif>[].obs;
  final trendingTerms = <String>[].obs;
  final autocompleteTerms = <String>[].obs;
  final isSearchBoxEmpty = true.obs;
  final showSearchResult = false.obs;
  final isSearching = false.obs;

  final RefreshController refreshController = RefreshController();
  final TextEditingController editingController = TextEditingController();

  @override
  Future<void> onInit() async {
    super.onInit();

    /// loading top 20 trending gif from tenor
    final tempList = await IbTenorService().getTrendingGifs();
    trendingGifs.addAll(tempList);

    /// loading top 20 trending terms from tenor
    final tempTermList = await IbTenorService().getTrendingTerms();
    trendingTerms.addAll(tempTermList);

    editingController.addListener(() async {
      isSearchBoxEmpty.value = editingController.text.isEmpty;
      if (editingController.text.isNotEmpty) {
        final tempList =
            await IbTenorService().getAutocomplete(editingController.text);
        autocompleteTerms.clear();
        autocompleteTerms.addAll(tempList);
      } else {
        showSearchResult.value = false;
      }
    });
  }

  Future<void> loadMore() async {
    try {
      if (trendingGifs.isNotEmpty && showSearchResult.isFalse) {
        final tempList = await IbTenorService()
            .getTrendingGifs(next: trendingGifs.last.next);
        trendingGifs.addAll(tempList);
      } else if (resultGifs.isNotEmpty && showSearchResult.isTrue) {
        final tempList = await IbTenorService().searchGif(
            searchText: editingController.text.trim(),
            next: resultGifs.last.next);
        resultGifs.addAll(tempList);
      }
      refreshController.loadComplete();
    } on Exception catch (_) {
      refreshController.loadFailed();
    }
  }

  Future<void> search() async {
    if (editingController.text.isEmpty) {
      return;
    }
    isSearching.value = true;
    IbUtils.hideKeyboard();
    showSearchResult.value = true;
    resultGifs.clear();
    final tempList = await IbTenorService()
        .searchGif(searchText: editingController.text.trim());
    resultGifs.addAll(tempList);
    isSearching.value = false;
  }

  @override
  void dispose() {
    editingController.dispose();
    refreshController.dispose();
    super.dispose();
  }
}
