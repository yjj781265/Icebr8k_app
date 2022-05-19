import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_friends_picker_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/people_nearby_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';
import 'package:lottie/lottie.dart';

class IbFriendsPicker extends StatelessWidget {
  final IbFriendsPickerController _controller;
  final int limit;
  final String buttonTxt;
  const IbFriendsPicker(this._controller,
      {this.limit = -1, this.buttonTxt = 'Invite', Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          centerTitle: false,
          title: Obx(() {
            final int pickedCount = _controller.items.keys
                .where((element) =>
                    !_controller.pickedUids.contains(element.id) &&
                    _controller.items[element] == true)
                .length;
            return Text(
                'Add${pickedCount == 0 ? '' : ' $pickedCount'} Friend(s)');
          }),
          actions: _controller.items.isEmpty
              ? null
              : [
                  TextButton(
                      onPressed: () {
                        _controller.selectAll();
                      },
                      child: const Text('Select All')),
                  Obx(() {
                    final result = _controller.allowEdit
                        ? _controller.items.keys.where(
                            (element) => _controller.items[element] == true)
                        : _controller.items.keys.where((element) =>
                            !_controller.pickedUids.contains(element.id) &&
                            _controller.items[element] == true);
                    return TextButton(
                        onPressed: () {
                          if (result.length > limit && limit != -1) {
                            IbUtils.showSimpleSnackBar(
                                msg: 'You can only pick up to $limit friend(s)',
                                backgroundColor: IbColors.primaryColor);
                            return;
                          }

                          Get.back(result: result.toList());
                        },
                        child: Text(
                          buttonTxt,
                          style: TextStyle(
                              color: _controller.allowEdit
                                  ? null
                                  : result.isEmpty
                                      ? IbColors.lightGrey
                                      : null),
                        ));
                  }),
                ],
        ),
        body: SafeArea(
          child: Obx(() {
            if (_controller.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                        width: 200,
                        height: 200,
                        child: Lottie.asset('assets/images/monkey_zen.json')),
                    const Text(
                      'Looks like you do not have any friends yet',
                      style: TextStyle(
                        color: IbColors.lightGrey,
                        fontSize: IbConfig.kNormalTextSize,
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          Get.back();
                          Get.to(() => PeopleNearbyPage());
                        },
                        child: const Text('See People Nearby 📍'))
                  ],
                ),
              );
            }

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
                      final int pickedCount = _controller.items.keys
                          .where((element) =>
                              !_controller.pickedUids.contains(element.id) &&
                              _controller.items[element] == true)
                          .length;
                      final bool meetMax = pickedCount == limit;
                      return Opacity(
                        opacity: (meetMax &&
                                    _controller.items[ibUser] == false) ||
                                _controller.pickedUids.contains(ibUser.id) &&
                                    !_controller.allowEdit
                            ? 0.5
                            : 1,
                        child: CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.trailing,
                            title: Text(ibUser.username),
                            secondary: IbUserAvatar(
                              avatarUrl: ibUser.avatarUrl,
                            ),
                            value: isPicked,
                            onChanged: (value) {
                              if (_controller.pickedUids.contains(ibUser.id) &&
                                  !_controller.allowEdit) {
                                return;
                              }

                              if (pickedCount >= limit &&
                                  limit != -1 &&
                                  value == true) {
                                IbUtils.showSimpleSnackBar(
                                    msg:
                                        'You can only pick up to $limit friend(s)',
                                    backgroundColor: IbColors.primaryColor);
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
        ),
      ),
    );
  }
}
