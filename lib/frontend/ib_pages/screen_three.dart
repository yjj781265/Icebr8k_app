import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/profile_page.dart';

class ScreenThree extends StatelessWidget {
  const ScreenThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      color: IbColors.lightBlue,
      child: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, value) {
            return [
              const SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.only(top: 48, left: 24, right: 24, bottom: 16),
                  child: Text(
                    'Answer the following 8 questions to get your Icebr8k journey started',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SliverPersistentHeader(
                  pinned: true,
                  delegate: PersistentHeader(
                    height: 56,
                    widget: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        SizedBox(
                          height: 8,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(
                                IbConfig.kScrollbarCornerRadius)),
                            child: LinearProgressIndicator(
                              color: IbColors.accentColor,
                              value: 0.8,
                              backgroundColor: IbColors.lightGrey,
                              minHeight: 8,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            '1/8',
                            style: TextStyle(fontSize: 24),
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
