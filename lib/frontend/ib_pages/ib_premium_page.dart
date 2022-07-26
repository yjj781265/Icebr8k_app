import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icebr8k/backend/controllers/user_controllers/ib_premium_controller.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_config.dart';
import 'package:icebr8k/frontend/ib_pages/menu_page.dart';
import 'package:icebr8k/frontend/ib_utils.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_card.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_dialog.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_elevated_button.dart';
import 'package:icebr8k/frontend/ib_widgets/ib_progress_indicator.dart';
import 'package:lottie/lottie.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class IbPremiumPage extends StatelessWidget {
  IbPremiumPage({Key? key}) : super(key: key);
  final IbPremiumController _controller = Get.put(IbPremiumController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Go Premium'),
        actions: [
          Obx(() {
            if (_controller.isPremium.isTrue) {
              return const SizedBox();
            }
            if (_controller.isRestoring.isTrue) {
              return Container(
                  width: 100,
                  height: 40,
                  alignment: Alignment.center,
                  child: const Center(
                      child: CircularProgressIndicator.adaptive(
                    strokeWidth: 2,
                  )));
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

        return Column(
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: IbElevatedButton(
                    color: IbColors.primaryColor,
                    textTrKey: 'I am In',
                    onPressed: () async {
                      _showPayWall();
                    },
                  ),
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  Widget _benefits() {
    return Container(
        margin: const EdgeInsets.all(8),
        decoration:
            BoxDecoration(border: Border.all(color: IbColors.lightGrey)),
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
                  )),
            ),
          ],
        ));
  }

  Future<void> _showPayWall() async {
    final Widget payWall = Obx(
      () => IbCard(
        child: SizedBox(
          height: 250,
          child: _controller.isLoadingProduct.isTrue
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      IbProgressIndicator(),
                      Text('Fetching Products...')
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _controller.products
                          .map((product) => Container(
                                margin: const EdgeInsets.all(4),
                                child: ListTile(
                                  onTap: () async {
                                    Get.back();
                                    if (GetPlatform.isIOS) {
                                      _showDisclosure(product);
                                      return;
                                    }
                                    await _controller.purchasePremium(product);
                                  },
                                  title: Text(
                                    product.title,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: IbConfig.kNormalTextSize),
                                  ),
                                  subtitle: Text(
                                      product.description.capitalizeFirst ??
                                          ''),
                                  trailing: Text(product.priceString,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: IbConfig.kPageTitleSize)),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ),
        ),
      ),
    );
    Get.bottomSheet(payWall, ignoreSafeArea: true);
    await _controller.loadProducts();
  }

  void _showDisclosure(Product product) {
    Get.dialog(IbDialog(
      title: 'Info',
      content: Text.rich(TextSpan(text: 'A ', children: [
        TextSpan(
          text: product.priceString,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const TextSpan(
          text:
              ' purchase will be applied to your apple account. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime within your AppStore settings. For more information, see our ',
        ),
        TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Get.to(() => TermAndConditionPage());
            },
          text: 'Term & Conditions',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: IbColors.darkPrimaryColor),
        ),
        const TextSpan(text: ' and '),
        TextSpan(
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              Get.to(() => PrivacyPolicyPage());
            },
          text: 'Privacy Policy',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: IbColors.darkPrimaryColor),
        ),
      ])),
      onPositiveTap: () async {
        Get.back();
        await _controller.purchasePremium(product);
      },
      subtitle: '',
    ));
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
                    'Member since ${IbUtils().readableDateTime(DateTime.parse(_controller.entitlementInfo!.originalPurchaseDate), showTime: true)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Last purchase at ${IbUtils().readableDateTime(DateTime.parse(_controller.entitlementInfo!.latestPurchaseDate), showTime: true)} from ${_controller.entitlementInfo!.store.name.capitalize}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    'Expires at ${IbUtils().readableDateTime(DateTime.parse(_controller.entitlementInfo!.expirationDate ?? ''), showTime: true)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Text(
                      'Will Renew: ${_controller.entitlementInfo!.willRenew.toString()}',
                      style: const TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                          color: IbColors.lightGrey)),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                      'Product ID: ${_controller.entitlementInfo!.productIdentifier} ',
                      style: const TextStyle(
                          fontSize: IbConfig.kDescriptionTextSize,
                          color: IbColors.lightGrey)),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Manage subscription from ${_controller.entitlementInfo!.store.name.capitalize}',
                    style: const TextStyle(
                        fontSize: IbConfig.kDescriptionTextSize,
                        fontStyle: FontStyle.italic,
                        color: IbColors.lightGrey),
                  ),
                ],
              ))
        ],
      ),
    );
  }
}
