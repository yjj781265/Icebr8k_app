import 'package:flutter/material.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_action_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class CircleSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: const [
                        CircleAvatar(
                          radius: 56,
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(child: Icon(Icons.edit)))
                      ],
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8))),
                        child: const TextField(
                          decoration: InputDecoration(border: InputBorder.none),
                        )),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8))),
                        child: const TextField(
                          minLines: 1,
                          maxLines: 5,
                          maxLength: 500,
                          decoration: InputDecoration(border: InputBorder.none),
                        )),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: IbActionButton(
                                color: IbColors.primaryColor,
                                iconData: Icons.add,
                                onPressed: () {},
                                text: ''),
                          ),
                          Expanded(
                            child: Scrollbar(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: IbUserAvatar(
                                          avatarUrl: IbUtils.getCurrentIbUser()!
                                              .avatarUrl),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    CheckboxListTile(
                      value: true,
                      onChanged: (value) {},
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: const Text(
                        'Public',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: IbConfig.kNormalTextSize),
                      ),
                      subtitle: const Text(
                        'Anyone can join the group',
                        style: TextStyle(
                            color: IbColors.lightGrey,
                            fontSize: IbConfig.kSecondaryTextSize),
                      ),
                    ),
                    const Divider(),
                    CheckboxListTile(
                      value: true,
                      onChanged: (value) {},
                      controlAffinity: ListTileControlAffinity.trailing,
                      title: const Text(
                        'Private',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: IbConfig.kNormalTextSize),
                      ),
                      subtitle: const Text(
                        'Only visible to those you share with',
                        style: TextStyle(
                            color: IbColors.lightGrey,
                            fontSize: IbConfig.kSecondaryTextSize),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              height: 64,
              width: double.infinity,
              child: IbElevatedButton(
                onPressed: () {},
                textTrKey: 'Create Circle',
              ),
            )
          ],
        ),
      ),
    );
  }
}
