import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NearbyTab extends StatefulWidget {
  @override
  State<NearbyTab> createState() => _NearbyTabState();
}

class _NearbyTabState extends State<NearbyTab>
    with SingleTickerProviderStateMixin {
  String title = 'friends_tab'.tr;
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 1, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text('People Nearby'),
        ),
        actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.sort))],
      ),
      body: const SafeArea(
        child: Text('People Nearby'),
      ),
    );
  }
}
