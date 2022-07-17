import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/backend/managers/ib_ad_manager.dart';

/// use this controller if you want to show inline ad in a list
/// if isMediumSizeBannerAd is set to true, it will return medium sized or regular size ad in random order
class IbAdController extends GetxController {
  final isLoading = true.obs;
  final isError = false.obs;
  final bool isMediumSizeBannerAd;
  late BannerAd bannerAd;
  final IbAdManager adManager = IbAdManager();

  IbAdController({this.isMediumSizeBannerAd = true}) {
    final bannerAdListener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) {
        isLoading.value = false;
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        isError.value = true;
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    );

    if (isMediumSizeBannerAd) {
      final list = [
        adManager.getBanner3(bannerAdListener: bannerAdListener),
        adManager.getBanner1(bannerAdListener: bannerAdListener),
        adManager.getBanner2(bannerAdListener: bannerAdListener)
      ];
      list.shuffle();
      bannerAd = list.first;
    } else {
      final list = [
        adManager.getBanner1(bannerAdListener: bannerAdListener),
        adManager.getBanner2(bannerAdListener: bannerAdListener)
      ];
      list.shuffle();
      bannerAd = list.first;
    }
  }

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    isError.value = false;
    await bannerAd.dispose();
    await bannerAd.load();
  }

  @override
  Future<void> onClose() async {
    await bannerAd.dispose();
    super.onClose();
  }
}
