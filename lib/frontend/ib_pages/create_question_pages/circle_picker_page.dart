import 'package:flutter/material.dart';
import 'package:icebr8k/backend/controllers/user_controllers/chat_tab_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../ib_config.dart';
import '../../ib_widgets/ib_user_avatar.dart';

class CirclePickerPage extends StatefulWidget {
  final List<ChatTabItem> pickedItems;
  const CirclePickerPage({this.pickedItems = const [], Key? key})
      : super(key: key);

  @override
  _CirclePickerPageState createState() => _CirclePickerPageState();
}

class _CirclePickerPageState extends State<CirclePickerPage> {
  final Map<ChatTabItem, bool> itemMap = {};
  final Map<ChatTabItem, bool> searchItemMap = {};
  final TextEditingController _editingController = TextEditingController();
  bool isSearching = false;

  @override
  void initState() {
    super.initState();

    ///setup itemMap

    for (final item in IbUtils.getCircleItems()) {
      if (widget.pickedItems.contains(item)) {
        itemMap[item] = true;
      } else {
        itemMap[item] = false;
      }
    }

    _editingController.addListener(() {
      searchItemMap.clear();
      searchItemMap.addAll(itemMap);
      if (_editingController.text.isEmpty) {
        isSearching = false;
      } else {
        searchItemMap.removeWhere((key, value) => !key.title
            .toLowerCase()
            .contains(_editingController.text.toLowerCase()));
        isSearching = true;
      }
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
            'Add${itemMap.values.where((element) => element == true).isEmpty ? '' : ' ${itemMap.values.where((element) => element == true).length}'} Circle(s)'),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'Add',
              style: TextStyle(
                fontSize: IbConfig.kNormalTextSize,
                color:
                    itemMap.values.where((element) => element == true).isEmpty
                        ? IbColors.lightGrey
                        : IbColors.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: TextField(
                  decoration: const InputDecoration(
                      hintText: 'Search Circle',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none),
                  controller: _editingController),
            ),
            Expanded(
              child: ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context, index) {
                  if (isSearching) {
                    final sortedList = searchItemMap.keys.toList();
                    sortedList.sort((a, b) => a.title.compareTo(b.title));
                    final item = sortedList[index];
                    return CheckboxListTile(
                        value: searchItemMap[item] ?? false,
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(item.title),
                        secondary: _buildCircleAvatar(item),
                        onChanged: (value) {
                          final bool isSelected = value ?? false;
                          setState(() {
                            searchItemMap[item] = isSelected;
                            itemMap[item] = isSelected;
                          });
                        });
                  }
                  final sortedList = itemMap.keys.toList();
                  sortedList.sort((a, b) => a.title.compareTo(b.title));
                  final item = sortedList[index];
                  return CheckboxListTile(
                      value: itemMap[item] ?? false,
                      controlAffinity: ListTileControlAffinity.trailing,
                      secondary: _buildCircleAvatar(item),
                      title: Text(item.title),
                      onChanged: (value) {
                        final bool isSelected = value ?? false;
                        setState(() {
                          itemMap[item] = isSelected;
                        });
                      });
                },
                itemCount: isSearching ? searchItemMap.length : itemMap.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleAvatar(ChatTabItem item) {
    if (item.ibChat.photoUrl.isEmpty) {
      return CircleAvatar(
        backgroundColor: IbColors.lightGrey,
        radius: 24,
        child: Text(
          item.ibChat.name[0],
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Theme.of(context).indicatorColor,
              fontSize: 24,
              fontWeight: FontWeight.bold),
        ),
      );
    } else {
      return IbUserAvatar(
        avatarUrl: item.ibChat.photoUrl,
      );
    }
  }
}
