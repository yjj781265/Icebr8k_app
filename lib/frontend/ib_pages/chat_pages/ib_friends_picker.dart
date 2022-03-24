import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_friends_picker_controller.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class IbFriendsPicker extends StatelessWidget {
  final IbFriendsPickerController _controller;
  const IbFriendsPicker(this._controller, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Obx(() {
          final int pickedCount = _controller.items.keys
              .where((element) =>
                  !_controller.pickedUids.contains(element.id) &&
                  _controller.items[element] == true)
              .length;
          return Text('Add ${pickedCount == 0 ? '' : pickedCount} member(s)');
        }),
        actions: [
          Obx(() {
            final int pickedCount = _controller.items.keys
                .where((element) =>
                    !_controller.pickedUids.contains(element.id) &&
                    _controller.items[element] == true)
                .length;
            return TextButton(
                onPressed: pickedCount == 0
                    ? null
                    : () {
                        Get.back(result: _controller.items.keys);
                      },
                child: const Text(
                  'Invite',
                  style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                ));
          }),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Theme.of(context).backgroundColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8))),
              child: TextField(
                decoration: const InputDecoration(
                    hintText: 'Search username',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none),
                controller: _controller.txtEditController,
              ),
            ),
            Expanded(
              child: ListView.separated(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemBuilder: (context, index) {
                  final ibUser = _controller.isSearching.isTrue
                      ? _controller.searchItems.keys.toList()[index]
                      : _controller.items.keys.toList()[index];
                  final isPicked = _controller.isSearching.isTrue
                      ? _controller.searchItems[ibUser]
                      : _controller.items[ibUser];
                  return Opacity(
                    opacity:
                        _controller.pickedUids.contains(ibUser.id) ? 0.5 : 1,
                    child: CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.trailing,
                        title: Text(ibUser.username),
                        secondary: IbUserAvatar(
                          avatarUrl: ibUser.avatarUrl,
                        ),
                        value: isPicked,
                        onChanged: (value) {
                          if (_controller.pickedUids.contains(ibUser.id)) {
                            return;
                          }
                          _controller.items[ibUser] = value ?? false;
                          _controller.searchItems[ibUser] = value ?? false;
                        }),
                  );
                },
                itemCount: _controller.isSearching.isTrue
                    ? _controller.searchItems.length
                    : _controller.items.length,
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(
                    height: 1,
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}
