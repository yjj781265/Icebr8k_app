import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/circle_info_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';

import '../../backend/models/ib_chat_models/ib_chat.dart';
import '../ib_config.dart';
import '../ib_pages/chat_pages/circle_info.dart';
import 'ib_user_avatar.dart';

class IbCircleCard extends StatelessWidget {
  final IbChat ibChat;

  const IbCircleCard(this.ibChat);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 200,
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        onTap: () {
          Get.to(() => CircleInfo(Get.put(CircleInfoController(ibChat.obs))));
        },
        child: IbCard(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (ibChat.photoUrl.isEmpty)
                  CircleAvatar(
                    backgroundColor: IbColors.lightGrey,
                    radius: 24,
                    child: AutoSizeText(
                      ibChat.name[0],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Theme.of(context).indicatorColor,
                          fontSize: IbConfig.kNormalTextSize,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                else
                  IbUserAvatar(
                    avatarUrl: ibChat.photoUrl,
                  ),
                AutoSizeText(
                  ibChat.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: IbConfig.kNormalTextSize),
                ),
                Text('${ibChat.memberUids.length} member(s)'),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  decoration: const BoxDecoration(
                      color: IbColors.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  padding: const EdgeInsets.all(2),
                  child: Text(
                    ibChat.isPublicCircle ? 'Public' : 'Private',
                    style: const TextStyle(
                        fontSize: IbConfig.kDescriptionTextSize),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
