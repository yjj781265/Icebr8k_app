import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/edit_emo_pic_controller.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emoji_keyboard.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_text_field.dart';
import 'package:image_picker/image_picker.dart';

import '../../ib_colors.dart';
import '../../ib_config.dart';

class EditEmoPicDetailPage extends StatefulWidget {
  final IbEmoPic ibEmoPic;
  final EditEmoPicController _controller;

  const EditEmoPicDetailPage(this.ibEmoPic, this._controller);

  @override
  State<EditEmoPicDetailPage> createState() => _EditEmoPicDetailPageState();
}

class _EditEmoPicDetailPageState extends State<EditEmoPicDetailPage> {
  late EditEmoPicController _controller;
  final TextEditingController emojiTeController = TextEditingController();
  final TextEditingController descTeController = TextEditingController();
  String oldUrl = '';
  String newUrl = '';

  @override
  void initState() {
    _controller = widget._controller;
    oldUrl = widget.ibEmoPic.url;
    descTeController.text = widget.ibEmoPic.description;
    emojiTeController.text = widget.ibEmoPic.emoji;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle headerStyle = TextStyle(
        fontWeight: FontWeight.bold, fontSize: IbConfig.kNormalTextSize);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            widget.ibEmoPic.url = oldUrl;
            Get.back();
          },
          icon: Platform.isAndroid
              ? const Icon(Icons.arrow_back)
              : const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: SafeArea(
        child: Column(
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
                        onTap: () => _showEmojiKeyBoard(context),
                        child: SizedBox(
                          width: 100,
                          child: IbTextField(
                              enabled: false,
                              textAlign: TextAlign.center,
                              textStyle: const TextStyle(
                                  fontSize: IbConfig.kSloganSize),
                              controller: emojiTeController,
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
                      widget.ibEmoPic.description =
                          descTeController.text.trim();
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
                errorWidget: (
                  context,
                  string,
                  d,
                ) =>
                    Container(
                  color: IbColors.lightGrey,
                  child: const Center(child: Text('Failed to load image')),
                ),
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
                errorBuilder: (context, obj, stackTrace) {
                  return Container(
                    height: 160 * 1.618 - 30,
                    width: 160,
                    color: IbColors.lightGrey,
                    child: const Center(child: Text('Failed to load image')),
                  );
                },
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
      ],
    );
    Get.bottomSheet(IbCard(child: options), ignoreSafeArea: false);
  }

  void _showEmojiKeyBoard(BuildContext context) {
    IbUtils.hideKeyboard();
    Get.bottomSheet(
        EmojiPicker(
            onEmojiSelected: (Category category, Emoji emoji) {
              Get.back();
              emojiTeController.text = emoji.emoji;
              widget.ibEmoPic.emoji = emojiTeController.text;
            },
            customWidget: (config, state) => IbEmojiKeyboard(config, state),
            config: Config(
                columns: 8,
                // Issue: https://github.com/flutter/flutter/issues/28894
                emojiSizeMax: 24 * (Platform.isIOS ? 1.30 : 1.0),
                bgColor: Theme.of(context).backgroundColor,
                indicatorColor: IbColors.primaryColor,
                iconColor: IbColors.lightGrey,
                skinToneIndicatorColor: Theme.of(context).indicatorColor,
                iconColorSelected: Theme.of(context).indicatorColor,
                progressIndicatorColor: IbColors.primaryColor,
                recentsLimit: 32,
                tabIndicatorAnimDuration: const Duration(milliseconds: 100),
                noRecentsStyle: TextStyle(
                    fontSize: IbConfig.kNormalTextSize,
                    color: Theme.of(context).indicatorColor),
                buttonMode: ButtonMode.CUPERTINO)),
        ignoreSafeArea: false);
  }
}
