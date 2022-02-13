import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/home_tab_controller.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class HomeTab extends StatelessWidget {
  HomeTab({Key? key}) : super(key: key);
  final HomeTabController _controller = Get.put(HomeTabController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('home'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        leading: Builder(
          builder: (context) => InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Obx(
              () => IbUserAvatar(
                avatarUrl: _controller.avatarUrl.value,
                radius: 16,
              ),
            ),
          ),
        ),
      ),
      drawer: const MenuPage(),
      body: ListView(
        controller: _controller.scrollController,
        children: const [
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
          ListTile(leading: Text('a')),
        ],
      ),
    );
  }
}
