import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/admin_controllers/feedback_chat_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_rich_text.dart';

class FeedBackChatPage extends StatelessWidget {
  const FeedBackChatPage(this._controller, {Key? key}) : super(key: key);
  final FeedbackChatController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Support/Feedback'),
            Text(
              'We will get back to you in 24hrs',
              style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: IbConfig.kDescriptionTextSize,
                  color: IbColors.lightGrey),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                reverse: true,
                itemBuilder: (context, index) {
                  final item = _controller.feedbacks[index];

                  return Padding(
                    padding: item.senderUid == IbUtils.getCurrentUid()
                        ? const EdgeInsets.only(left: 32.0)
                        : const EdgeInsets.only(right: 32.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment:
                          item.senderUid == IbUtils.getCurrentUid()
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.senderUid != IbUtils.getCurrentUid() &&
                            !_controller.isAdmin)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Icon(
                              Icons.support_agent,
                              size: 32,
                              color: IbColors.accentColor,
                            ),
                          ),
                        if (item.senderUid != IbUtils.getCurrentUid() &&
                            _controller.isAdmin)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: IbColors.accentColor,
                            ),
                          ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              crossAxisAlignment:
                                  item.senderUid == IbUtils.getCurrentUid()
                                      ? CrossAxisAlignment.end
                                      : CrossAxisAlignment.start,
                              children: [
                                IbCard(
                                    child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: IbRichText(
                                    defaultTextStyle: TextStyle(
                                        fontSize: IbConfig.kNormalTextSize,
                                        color:
                                            Theme.of(context).indicatorColor),
                                    string: item.content,
                                  ),
                                )),
                                Text(
                                  IbUtils.readableDateTime(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          (item.timestamp as Timestamp)
                                              .millisecondsSinceEpoch),
                                      showTime: true),
                                  style: const TextStyle(
                                      color: IbColors.lightGrey,
                                      fontSize: IbConfig.kDescriptionTextSize),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                },
                itemCount: _controller.feedbacks.length,
              ),
            ),
          ),
          Container(
            height: 56,
            alignment: Alignment.centerLeft,
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: IbColors.lightGrey.withOpacity(0.3),
              borderRadius: const BorderRadius.all(
                Radius.circular(8),
              ),
            ),
            child: TextField(
              scrollPadding: EdgeInsets.zero,
              minLines: 1,
              maxLines: 8,
              maxLength: 2000,
              controller: _controller.textEditingController,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                suffixIcon: SizedBox(
                  child: IconButton(
                      onPressed: () async {
                        await _controller.addFeedback();
                      },
                      icon: const Icon(Icons.send)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                counterText: '',
                fillColor: IbColors.lightGrey,
                border: InputBorder.none,
                hintText: 'Questions, Feedbacks, Comments',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
