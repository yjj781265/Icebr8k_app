import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/ib_tenor_controller.dart';
import 'package:icebr8k/backend/models/ib_gif.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IbTenorPage extends StatelessWidget {
  final IbTenorController _controller = Get.put(IbTenorController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              flex: 8,
              child: TextField(
                onSubmitted: (value) async {
                  await _controller.search();
                },
                textInputAction: TextInputAction.search,
                controller: _controller.editingController,
                autofocus: true,
                decoration: InputDecoration(
                  suffixIcon: Obx(
                    () => _controller.isSearchBoxEmpty.value
                        ? const SizedBox()
                        : IconButton(
                            onPressed: () {
                              _controller.editingController.clear();
                            },
                            icon: const Icon(Icons.cancel)),
                  ),
                  hintText: '🔍 Search Tenor',
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                await _controller.search();
              },
              child: const Text(
                'Search',
                style: TextStyle(fontSize: IbConfig.kNormalTextSize),
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () {
          IbUtils.hideKeyboard();
        },
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// show trending keywords when search box is empty
              if (_controller.isSearchBoxEmpty.isTrue)
                Obx(
                  () => SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _controller.trendingTerms
                          .map((element) => Container(
                                margin: const EdgeInsets.all(4),
                                child: InkWell(
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onTap: () async {
                                    _controller.editingController.text =
                                        element;
                                    await _controller.search();
                                  },
                                  child: Ink(
                                    decoration: BoxDecoration(
                                        color: IbUtils.getRandomColor(),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(6))),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      element,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),

              /// show auto complete keywords when search box is not empty
              if (_controller.isSearchBoxEmpty.isFalse)
                Obx(
                  () => SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _controller.autocompleteTerms
                          .map((element) => Container(
                                margin: const EdgeInsets.all(4),
                                child: InkWell(
                                  customBorder: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  onTap: () async {
                                    _controller.editingController.text =
                                        element;
                                    await _controller.search();
                                  },
                                  child: Ink(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(6)),
                                        color: IbColors.primaryColor),
                                    padding: const EdgeInsets.all(8),
                                    child: Text(
                                      element,
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
              const SizedBox(
                height: 4,
              ),

              /// show trending gif when search box is empty
              if (_controller.showSearchResult.isFalse)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SmartRefresher(
                      controller: _controller.refreshController,
                      enablePullUp: true,
                      enablePullDown: false,
                      onLoading: () async {
                        await _controller.loadMore();
                      },
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: _controller.trendingGifs
                              .map(
                                (e) => iBGifItem(e),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              if (_controller.showSearchResult.isTrue &&
                  _controller.isSearching.isTrue)
                const Expanded(
                    child: Center(
                  child: IbProgressIndicator(),
                )),

              /// show search result gif when search is done
              if (_controller.showSearchResult.isTrue &&
                  _controller.isSearching.isFalse)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SmartRefresher(
                      controller: _controller.refreshController,
                      enablePullUp: true,
                      enablePullDown: false,
                      onLoading: () async {
                        await _controller.loadMore();
                      },
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: StaggeredGrid.count(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          children: _controller.resultGifs
                              .map(
                                (e) => iBGifItem(e),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleItemClick(String url) {
    Get.back(result: url);
  }

  Widget iBGifItem(IbGif e) {
    return Stack(
      children: [
        SizedBox(
          height: e.height.toDouble(),
          width: e.width.toDouble(),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(
              Radius.circular(8),
            ),
            child: CachedNetworkImage(
              placeholder: (context, str) => Container(
                decoration: BoxDecoration(
                  color: IbColors.lightGrey.withOpacity(0.8),
                ),
                height: e.height.toDouble(),
                width: e.width.toDouble(),
              ),
              imageUrl: e.url,
              fit: BoxFit.fill,
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _handleItemClick(e.url),
            ),
          ),
        ),
      ],
    );
  }
}
