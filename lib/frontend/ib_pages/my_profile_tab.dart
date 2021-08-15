import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/home_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

import '../ib_utils.dart';

class MyProfileTab extends StatefulWidget {
  const MyProfileTab({Key? key}) : super(key: key);

  @override
  _MyProfileTabState createState() => _MyProfileTabState();
}

class _MyProfileTabState extends State<MyProfileTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: 2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: IbColors.lightBlue,
        body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        color: IbColors.primaryColor,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomLeft,
                          children: [
                            /// avatar
                            Positioned(
                              bottom: -32,
                              left: 16,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  IbUserAvatar(
                                      radius: 32,
                                      avatarUrl:
                                          IbUtils.getCurrentIbUser() == null
                                              ? ''
                                              : IbUtils.getCurrentIbUser()!
                                                  .avatarUrl),
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: FloatingActionButton(
                                      backgroundColor: IbColors.lightBlue,
                                      onPressed: () {},
                                      child: const Icon(
                                        Icons.edit_outlined,
                                        size: 16,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      /// name info
                      Padding(
                        padding: const EdgeInsets.only(top: 40, left: 16),
                        child: Obx(
                          () => Column(
                            children: [
                              Text(
                                  '@${_homeController.currentIbUsername.value}',
                                  style: const TextStyle(
                                      fontSize: IbConfig.kPageTitleSize,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                _homeController.currentIbName.value,
                                style: const TextStyle(
                                    fontSize: IbConfig.kNormalTextSize),
                              ),
                              Text(_homeController.currentIbUser!.description,
                                  style: const TextStyle(
                                      fontSize: IbConfig.kDescriptionTextSize)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ];
            },
            body: ListView(
              children: [
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafaf'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
                Text('fdafafafdflajkf;afj;lafjl;afjl;ajf;lfj'),
              ],
            )));
  }
}
