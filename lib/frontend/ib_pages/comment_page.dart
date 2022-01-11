import 'package:flutter/material.dart';
import 'package:icebr8k/backend/models/ib_question.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_user_avatar.dart';

class CommentPage extends StatelessWidget {
  final IbQuestion ibQuestion;

  const CommentPage(this.ibQuestion);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ibQuestion.question),
            const Text(
              '121 comments',
              style: TextStyle(fontSize: IbConfig.kSecondaryTextSize),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemBuilder: (context, index) {
                return Builder(builder: (context) {
                  if (index == 0) {
                    // return the header
                    return SizedBox(
                      height: 56,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          DropdownButton<String>(
                            value: 'A',
                            items: <String>['A', 'B', 'C', 'D']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (_) {},
                          ),
                        ],
                      ),
                    );
                  }
                  index -= 1;
                  return Column(
                    children: [
                      CommentItem(),
                      const Divider(
                        color: IbColors.lightGrey,
                        height: 1,
                        thickness: 1,
                      ),
                    ],
                  );
                });
              },
              itemCount: 100,
            ),
          ),
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.all(
                    Radius.circular(IbConfig.kTextBoxCornerRadius)),
                border: Border.all(
                  color: IbColors.primaryColor,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: TextField(
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.newline,
                  style: const TextStyle(fontSize: IbConfig.kNormalTextSize),
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                      hintStyle: const TextStyle(
                          color: IbColors.lightGrey,
                          fontSize: IbConfig.kNormalTextSize),
                      hintText: 'Type something creative',
                      border: InputBorder.none,
                      suffixIcon: false
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator()),
                            )
                          : IconButton(
                              icon: const Icon(
                                Icons.send_outlined,
                                color: IbColors.primaryColor,
                              ),
                              onPressed: () async {},
                            )),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CommentItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: () {},
        child: Ink(
          color: Theme.of(context).primaryColor,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IbUserAvatar(
                  avatarUrl: IbUtils.getCurrentIbUser()!.avatarUrl,
                  radius: 16,
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            'username',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: IbConfig.kNormalTextSize),
                          ),
                        ],
                      ),
                      const Text(
                        '1-10/2022',
                        style: TextStyle(
                            fontSize: IbConfig.kDescriptionTextSize,
                            color: IbColors.lightGrey),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      const Text(
                        'content is content is content',
                        style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                      ),
                      TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.reply,
                            size: 16,
                          ),
                          label: const Text(
                            'Reply',
                            style: TextStyle(
                                fontSize: IbConfig.kSecondaryTextSize),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
