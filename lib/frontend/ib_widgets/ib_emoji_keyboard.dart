import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:emoji_picker_flutter/src/emoji_view_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

class IbEmojiKeyboard extends EmojiPickerBuilder {
  IbEmojiKeyboard(Config config, EmojiViewState state) : super(config, state);

  @override
  _IbEmojiKeyboardState createState() => _IbEmojiKeyboardState();
}

class _IbEmojiKeyboardState extends State<IbEmojiKeyboard>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  late TabController _tabController;
  List<Emoji> searchResults = [];

  int currentIndex = 0;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: widget.state.categoryEmoji.length, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentIndex = _tabController.index;
      });
    });
    _controller.addListener(() async {
      if (_controller.text.isEmpty) {
        setState(() {
          isSearching = false;
        });
      } else {
        setState(() {
          isSearching = true;
          searchResults.clear();
        });
        searchResults =
            await EmojiPickerUtils().searchEmoji(_controller.text.trim());
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IbCard(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: SizedBox(
          height: 400,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    borderRadius: const BorderRadius.all(Radius.circular(16))),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      suffixIcon: _controller.text.isEmpty
                          ? null
                          : IconButton(
                              onPressed: () {
                                _controller.clear();
                              },
                              icon: const Icon(Icons.cancel)),
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search Emoji'),
                ),
              ),
              if (!isSearching)
                TabBar(
                  tabs: [
                    Icon(
                      widget.config.categoryIcons.recentIcon,
                      size: 16,
                    ),
                    Icon(widget.config.categoryIcons.smileyIcon, size: 18),
                    Icon(widget.config.categoryIcons.animalIcon, size: 18),
                    Icon(widget.config.categoryIcons.foodIcon, size: 18),
                    Icon(widget.config.categoryIcons.activityIcon, size: 18),
                    Icon(widget.config.categoryIcons.travelIcon, size: 18),
                    Icon(widget.config.categoryIcons.objectIcon, size: 18),
                    Icon(widget.config.categoryIcons.symbolIcon, size: 18),
                    Icon(widget.config.categoryIcons.flagIcon, size: 18),
                  ],
                  controller: _tabController,
                ),
              if (!isSearching)
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: widget.state.categoryEmoji
                        .map((e) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(e.category.name.toUpperCase()),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Scrollbar(
                                      radius: const Radius.circular(16),
                                      child: SingleChildScrollView(
                                        child: Wrap(
                                          alignment: WrapAlignment.spaceEvenly,
                                          children: e.emoji
                                              .map((emoji) => Tooltip(
                                                    message: emoji.name,
                                                    child: SizedBox(
                                                      width: Get.width / 8,
                                                      child: TextButton(
                                                        onPressed: () {
                                                          widget.state.onEmojiSelected(
                                                              widget
                                                                  .state
                                                                  .categoryEmoji[
                                                                      currentIndex]
                                                                  .category,
                                                              emoji);
                                                        },
                                                        child: Text(emoji.emoji,
                                                            style: const TextStyle(
                                                                fontSize: IbConfig
                                                                    .kSloganSize)),
                                                      ),
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ))
                        .toList(),
                  ),
                ),
              if (isSearching)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Scrollbar(
                      radius: const Radius.circular(16),
                      child: SingleChildScrollView(
                        child: Wrap(
                          children: searchResults
                              .map((emoji) => Tooltip(
                                    message: emoji.name,
                                    child: SizedBox(
                                      width: Get.width / 8,
                                      child: TextButton(
                                        onPressed: () {
                                          widget.state.onEmojiSelected(
                                              widget
                                                  .state
                                                  .categoryEmoji[currentIndex]
                                                  .category,
                                              emoji);
                                        },
                                        child: Text(emoji.emoji,
                                            style: const TextStyle(
                                                fontSize:
                                                    IbConfig.kSloganSize)),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
