import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icebr8k/backend/controllers/user_controllers/setup_controller.dart';
import 'package:icebr8k/backend/models/ib_emo_pic.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_emo_pic_card.dart';
import 'package:image_picker/image_picker.dart';

import '../../ib_colors.dart';
import '../../ib_utils.dart';

class SetupPageTwo extends StatelessWidget {
  final SetupController _controller;

  const SetupPageTwo(this._controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: IbUtils().hideKeyboard,
          child: SafeArea(
              child: Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: bodyWidget(context)),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: SizedBox(
                          height: 56,
                          child: IbElevatedButton(
                            color: IbColors.errorRed,
                            textTrKey: 'back',
                            onPressed: () {
                              Get.back();
                            },
                            icon: const Icon(Icons.arrow_back_ios),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 6,
                        child: SizedBox(
                          height: 56,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: IbElevatedButton(
                              color: IbColors.primaryColor,
                              textTrKey: 'next',
                              onPressed: () {
                                _controller.validatePageTwo();
                              },
                              icon: const Icon(Icons.arrow_back_ios),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
        ),
      ),
    );
  }

  Widget bodyWidget(BuildContext context) {
    return Scrollbar(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                      flex: 8,
                      child: Text(
                        'Create your EmoPics',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: IbConfig.kSloganSize,
                            fontWeight: FontWeight.bold),
                      )),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius:
                              const BorderRadius.all(Radius.circular(16)),
                          color: Theme.of(context).backgroundColor,
                        ),
                        child: const Text(
                          'Step 2/3',
                          style: TextStyle(fontSize: IbConfig.kNormalTextSize),
                        ),
                      ))
                ],
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'This is my',
                style: TextStyle(fontSize: IbConfig.kPageTitleSize),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Obx(() => CarouselSlider(
                  items: _controller.emoPics
                      .map((element) => IbEmoPicCard(
                            emoPic: element,
                            onTap: () => showEditAvatarBottomSheet(
                                context: context, emoPic: element),
                          ))
                      .toList(),
                  options: CarouselOptions(
                      height: 350,
                      padEnds: false,
                      enableInfiniteScroll: false,
                      viewportFraction: 0.6,
                      aspectRatio: 0.618),
                )),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Double tap on the picture to enlarge',
                style: TextStyle(
                    color: IbColors.lightGrey,
                    fontSize: IbConfig.kSecondaryTextSize),
              ),
            ),
            const SizedBox(
              height: 32,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text:
                          'P.S Make sure your pictures are clear, and represents the real you. Otherwise your profile may get ',
                      style: TextStyle(color: Theme.of(context).indicatorColor),
                      children: [
                        const TextSpan(
                            text: 'rejected ',
                            style: TextStyle(color: IbColors.errorRed)),
                        TextSpan(
                          text: 'by Icebr8k.',
                          style: TextStyle(
                              color: Theme.of(context).indicatorColor),
                        )
                      ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showEditAvatarBottomSheet(
      {required BuildContext context, required IbEmoPic emoPic}) {
    final Widget options = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          onTap: () async {
            Get.back();
            final XFile? pickedFile = await _controller.picker.pickImage(
              source: ImageSource.camera,
              preferredCameraDevice: CameraDevice.front,
              imageQuality: IbConfig.kImageQuality,
            );

            if (pickedFile != null) {
              emoPic.url = pickedFile.path;
              emoPic.timestampInMs = DateTime.now().millisecondsSinceEpoch;
              _controller.updateEmoPic(emoPic);
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
            final XFile? pickedFile = await _controller.picker.pickImage(
              source: ImageSource.gallery,
              preferredCameraDevice: CameraDevice.front,
              imageQuality: IbConfig.kImageQuality,
            );
            print(pickedFile);
            if (pickedFile != null) {
              print(pickedFile.path);
              emoPic.url = pickedFile.path;
              _controller.updateEmoPic(emoPic);
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

    Get.bottomSheet(SafeArea(child: IbCard(child: options)));
  }
}
