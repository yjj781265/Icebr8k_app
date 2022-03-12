import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/edit_emo_pic_controller.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/frontend/ib_pages/ib_tenor_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:image_picker/image_picker.dart';

import '../../ib_colors.dart';
import '../../ib_config.dart';

class EditEmoPicDetailPage extends StatefulWidget {
  final IbEmoPic ibEmoPic;

  const EditEmoPicDetailPage(this.ibEmoPic);

  @override
  State<EditEmoPicDetailPage> createState() => _EditEmoPicDetailPageState();
}

class _EditEmoPicDetailPageState extends State<EditEmoPicDetailPage> {
  final EditEmoPicController _controller = Get.find();
  final TextEditingController emojiTeController = TextEditingController();
  final TextEditingController descTeController = TextEditingController();
  String emojiStr = '';
  String oldUrl = '';

  @override
  void initState() {
    emojiStr = widget.ibEmoPic.emoji;
    oldUrl = widget.ibEmoPic.url;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle headerStyle = TextStyle(
        fontWeight: FontWeight.bold, fontSize: IbConfig.kNormalTextSize);
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text(
                        'photo'.tr,
                        style: headerStyle,
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          showMediaBottomSheet(context);
                        },
                        child: _handleEmoPic()),
                    const Divider(
                      thickness: 2,
                    ),
                    InkWell(
                      onTap: _showEmojiKeyBoard,
                      child: SizedBox(
                        width: 100,
                        child: IbTextField(
                            enabled: false,
                            textAlign: TextAlign.center,
                            textStyle:
                                const TextStyle(fontSize: IbConfig.kSloganSize),
                            controller: emojiTeController,
                            text: emojiStr,
                            titleIcon: const Icon(
                              Icons.emoji_emotions,
                              color: Colors.orangeAccent,
                            ),
                            titleTrKey: 'emoji',
                            hintTrKey: '',
                            onChanged: (text) {}),
                      ),
                    ),
                    IbTextField(
                        controller: descTeController,
                        charLimit: 20,
                        text: widget.ibEmoPic.description,
                        textStyle: TextStyle(
                            color: Theme.of(context).indicatorColor,
                            fontSize: IbConfig.kNormalTextSize,
                            fontWeight: FontWeight.bold),
                        titleIcon: const Icon(
                          Icons.description,
                          color: IbColors.primaryColor,
                        ),
                        titleTrKey: 'description',
                        hintTrKey: 'description_hint',
                        onChanged: (text) {}),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: IbElevatedButton(
                  textTrKey: 'confirm',
                  onPressed: () async {
                    widget.ibEmoPic.emoji = emojiTeController.text;
                    widget.ibEmoPic.description = descTeController.text.trim();
                    await _controller.uploadEmoPic(
                        emoPic: widget.ibEmoPic, oldUrl: oldUrl);
                  },
                  icon: const Icon(Icons.check_circle_rounded),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _handleEmoPic() {
    if (widget.ibEmoPic.url.isEmpty) {
      return Container(
        width: 160,
        height: 160 * 1.618 - 30,
        decoration: const BoxDecoration(
            color: IbColors.lightGrey,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8), topRight: Radius.circular(8))),
        child: const Icon(
          Icons.add,
          size: 48,
        ),
      );
    } else {
      return widget.ibEmoPic.url.contains('http')
          ? ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8), topRight: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: widget.ibEmoPic.url,
                fit: BoxFit.cover,
                width: 160,
                height: 160 * 1.618 - 30,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                File(widget.ibEmoPic.url),
                fit: BoxFit.cover,
                width: 160,
                height: 160 * 1.618 - 30,
              ),
            );
    }
  }

  void showMediaBottomSheet(BuildContext context) {
    final Widget options = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            Get.back();
            final _picker = ImagePicker();
            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.camera,
              imageQuality: IbConfig.kImageQuality,
            );

            if (pickedFile != null) {
              setState(() {
                widget.ibEmoPic.url = pickedFile.path;
              });
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  Icon(
                    Icons.camera_alt_outlined,
                    color: IbColors.primaryColor,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text('Take a photo',
                      style: TextStyle(fontSize: IbConfig.kNormalTextSize)),
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            Get.back();
            final _picker = ImagePicker();

            final XFile? pickedFile = await _picker.pickImage(
              source: ImageSource.gallery,
              imageQuality: IbConfig.kImageQuality,
            );

            if (pickedFile != null) {
              setState(() {
                widget.ibEmoPic.url = pickedFile.path;
              });
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  Icon(
                    Icons.photo_album_outlined,
                    color: IbColors.errorRed,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Choose from gallery',
                    style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                  ),
                ],
              ),
            ),
          ),
        ),
        InkWell(
          onTap: () async {
            Get.back();
            final gifUrl = await Get.to(
              () => IbTenorPage(),
            );
            if (gifUrl != null && gifUrl.toString().isNotEmpty) {
              setState(() {
                widget.ibEmoPic.url = gifUrl.toString();
              });
            }
          },
          child: Ink(
            height: 56,
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  Icon(
                    Icons.gif,
                    color: IbColors.accentColor,
                    size: 24,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Choose GIF from Tenor',
                    style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    Get.bottomSheet(IbCard(child: options), ignoreSafeArea: false);
  }

  void _showEmojiKeyBoard() {
    IbUtils.hideKeyboard();
    Get.bottomSheet(
        IbCard(
          child: SizedBox(
              height: Get.height / 2,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  setState(() {
                    emojiStr = emoji.emoji;
                    widget.ibEmoPic.emoji = emojiStr;
                  });
                  Get.back();
                },
                config: Config(
                  emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                ),
              )),
        ),
        ignoreSafeArea: false);
  }
}
