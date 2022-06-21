import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_premium_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:lottie/lottie.dart';

class IbPremiumPage extends StatelessWidget {
  IbPremiumPage({Key? key}) : super(key: key);
  final IbPremiumController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Go Premium'),
        actions: [
          Obx(() {
            if (_controller.isPremium.isTrue) {
              return const SizedBox();
            }
            return TextButton(
                onPressed: () async {
                  await _controller.restorePurchase();
                },
                child: const Text('Restore Purchase'));
          }),
        ],
      ),
      body: Obx(() {
        if (_controller.isLoading.isTrue) {
          return const Center(
            child: IbProgressIndicator(),
          );
        }

        if (_controller.isPremium.isTrue &&
            _controller.entitlementInfo != null) {
          return _premiumBody();
        }

        return Container(
          padding: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/default_cover_photo.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const IbCard(
                        child: Icon(
                          Icons.workspace_premium,
                          color: IbColors.primaryColor,
                          size: 48,
                        ),
                      ),
                      IbCard(
                        elevation: 0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Icebr8k Premium',
                            style: GoogleFonts.robotoSlab(
                                textStyle: const TextStyle(
                                    fontSize: IbConfig.kSloganSize,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      _benefits(),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SafeArea(
                    child: SizedBox(
                      width: double.infinity,
                      child: IbElevatedButton(
                        color: IbColors.primaryColor,
                        textTrKey: 'I am In',
                        onPressed: () async {
                          showPayWall();
                        },
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  Widget _benefits() {
    return IbCard(
        color: IbColors.lightBlue,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  Text(
                    '• No Ads',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: IbConfig.kNormalTextSize,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: IbColors.primaryColor,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: const [
                  Text('• Create Unlimited Polls per Day',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: IbConfig.kNormalTextSize,
                          fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: 4,
                  ),
                  Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: IbColors.primaryColor,
                  )
                ],
              ),
            ),
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: AutoSizeText('• Image Polls',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: IbConfig.kNormalTextSize,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: IbColors.primaryColor,
                )
              ],
            ),
            Row(
              children: const [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('• Seen and Typing Indicator in Chat',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: IbConfig.kNormalTextSize,
                          fontWeight: FontWeight.bold)),
                ),
                SizedBox(
                  width: 4,
                ),
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: IbColors.primaryColor,
                )
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: AutoSizeText('• More Premium Features Coming Soon 😃',
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: IbConfig.kPageTitleSize,
                    color: Colors.black,
                  )),
            ),
          ],
        ));
  }

  void showPayWall() {
    final Widget payWall = Obx(
      () => IbCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _controller.offerings
                .map((element) => Container(
                      margin: const EdgeInsets.all(4),
                      child: ListTile(
                        onTap: () async {
                          Get.back();
                          _controller.purchasePremium(
                              element.availablePackages.first.product);
                        },
                        title: Text(
                          element.availablePackages.first.product.title,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: IbConfig.kNormalTextSize),
                        ),
                        subtitle: Text(element.availablePackages.first.product
                                .description.capitalizeFirst ??
                            ''),
                        trailing: Text(
                            element.availablePackages.first.product.priceString,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: IbConfig.kPageTitleSize)),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
    Get.bottomSheet(payWall, ignoreSafeArea: true);
  }

  Widget _premiumBody() {
    return SizedBox.expand(
      child: Column(
        children: [
          Flexible(
              flex: 5,
              child: SizedBox(
                  width: 300,
                  height: 300,
                  child: Lottie.asset('assets/images/premium.json'))),
          Flexible(
              flex: 2,
              child: Column(
                children: [
                  Text(
                    'Member since ${IbUtils.readableDateTime(DateTime.parse(_controller.entitlementInfo!.originalPurchaseDate), showTime: true)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Last purchase at ${IbUtils.readableDateTime(DateTime.parse(_controller.entitlementInfo!.latestPurchaseDate), showTime: true)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Expires at ${IbUtils.readableDateTime(DateTime.parse(_controller.entitlementInfo!.expirationDate ?? ''), showTime: true)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                      'Will Renew: ${_controller.entitlementInfo!.willRenew.toString()}'),
                  Text(
                      'Product ID: ${_controller.entitlementInfo!.productIdentifier} '),
                  Text(
                    'Manage subscription from ${GetPlatform.isAndroid ? 'Google Play Store' : 'iOS App Store'}',
                    style: const TextStyle(
                        fontStyle: FontStyle.italic, color: IbColors.lightGrey),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
