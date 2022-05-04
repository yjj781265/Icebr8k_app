import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/social_tab_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

import '../../backend/models/ib_user.dart';
import '../ib_widgets/ib_user_avatar.dart';

class SelectChatPage extends StatefulWidget {
  const SelectChatPage({Key? key}) : super(key: key);

  @override
  State<SelectChatPage> createState() => _SelectChatPageState();
}

class _SelectChatPageState extends State<SelectChatPage> {
  Map<ChatTabItem, bool> selectedMap = {};

  @override
  void initState() {
    final chatTabItems = IbUtils.getAllChatTabItems();
    for (final item in chatTabItems) {
      selectedMap[item] = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${selectedMap.values.where((element) => element).length} Chat(s) Selected'),
        actions: [
          TextButton(
              onPressed: () {
                Get.back(
                    result: selectedMap.keys
                        .where((element) => selectedMap[element] ?? false)
                        .toList());
              },
              child: Text('confirm'.tr))
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final list = selectedMap.keys.toList();
          list.sort((a, b) => a.title.compareTo(b.title));
          final item = list[index];

          return CheckboxListTile(
            value: selectedMap[item],
            onChanged: (value) {
              setState(() {
                selectedMap[item] = value ?? false;
              });
            },
            title: Text(item.title),
            secondary: item.ibChat.isCircle
                ? _buildCircleAvatar(item)
                : _buildAvatar(item.avatars),
          );
        },
        itemCount: selectedMap.length,
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

  Widget _buildAvatar(List<IbUser> avatarUsers) {
    final double radius = avatarUsers.length > 1 ? 10 : 24;
    return CircleAvatar(
      backgroundColor: Theme.of(context).backgroundColor,
      radius: 24,
      child: Wrap(
        spacing: 1,
        runSpacing: 1,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.center,
        children: avatarUsers
            .map((e) => IbUserAvatar(
                  avatarUrl: e.avatarUrl,
                  radius: radius,
                ))
            .toList(),
      ),
    );
  }
}
