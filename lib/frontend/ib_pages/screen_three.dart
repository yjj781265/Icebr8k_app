import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/set_up_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';

class ScreenThree extends StatelessWidget {
  ScreenThree({Key? key}) : super(key: key);
  final SetUpController _setUpController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IbColors.lightBlue,
      appBar: AppBar(
        backgroundColor: IbColors.lightBlue,
        leading: IconButton(
            onPressed: () {
              _setUpController.liquidController.animateToPage(page: 1);
            },
            icon: const Icon(Icons.arrow_back_ios)),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.check)),
        ],
      ),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 16, right: 24, bottom: 16),
                  child: Text(
                    'Finally, answer the following 8 questions to get your Icebr8k journey started',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: PersistentHeader(
                    widget: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(
                                IbConfig.kScrollbarCornerRadius)),
                            child: LinearProgressIndicator(
                              color: IbColors.accentColor,
                              value: 1 / 8,
                              backgroundColor: IbColors.lightGrey,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.0),
                          child: Text(
                            '1/8',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  )),
            ];
          },
          body: Placeholder(),
        ),
      ),
    );
  }
}
