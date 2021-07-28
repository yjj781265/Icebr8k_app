import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_colors.dart';

class ScorePage extends StatefulWidget {
  const ScorePage({Key? key}) : super(key: key);

  @override
  _ScorePageState createState() => _ScorePageState();
}

class _ScorePageState extends State<ScorePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
    _tabController.addListener(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: IbColors.lightBlue,
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: 'Friends',
              ),
              Tab(text: 'People Nearby'),
            ],
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            labelColor: Colors.black,
            unselectedLabelColor: IbColors.lightGrey,
            indicatorColor: IbColors.primaryColor,
          ),
          Expanded(
              child: TabBarView(
            children: [
              MyFriendsTab(),
              Center(
                child: Text('People Nearby tab'),
              )
            ],
            controller: _tabController,
          ))
        ],
      ),
    );
  }
}

class MyFriendsTab extends StatelessWidget {
  const MyFriendsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView.builder(
          itemBuilder: (context, index) => ListTile(
                trailing: IconButton(
                  icon: const Icon(
                    Icons.message_outlined,
                    color: IbColors.accentColor,
                  ),
                  splashColor: IbColors.accentColor.withOpacity(0.5),
                  onPressed: () {
                    print('message');
                  },
                ),
                leading: const CircleAvatar(),
                title: const Text('Username'),
                subtitle: LinearProgressIndicator(
                  value: 10,
                ),
              )),
    );
  }
}
