import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbAdManager {
  static const String kTestBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String kTestRewardId = 'ca-app-pub-3940256099942544/5224354917';

  Future<void> showRewardAd(
      FullScreenContentCallback<RewardedAd> callback) async {
    RewardedAd myAd;
    IbUtils.showSimpleSnackBar(
        msg: 'Loading Ad...', backgroundColor: IbColors.primaryColor);
    await RewardedAd.load(
        adUnitId: kTestRewardId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            myAd = ad;
            myAd.fullScreenContentCallback = callback;
            myAd.show(
                onUserEarnedReward: (view, item) =>
                    print('I WATCHED THE VIDEO'));
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ));
  }

  /// return loaded banner
  BannerAd getBanner1() {
    final BannerAdListener listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    );
    final BannerAd myBanner = BannerAd(
      adUnitId: kTestBannerId,
      size: AdSize(height: 50, width: Get.width.toInt()),
      request: const AdRequest(),
      listener: listener,
    );
    return myBanner;
  }

  /// return  banner
  BannerAd getBanner2() {
    final BannerAdListener listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    );
    final BannerAd myBanner = BannerAd(
      adUnitId: kTestBannerId,
      size: AdSize(height: 50, width: Get.width.toInt()),
      request: const AdRequest(),
      listener: listener,
    );
    return myBanner;
  }

  /// return medium size banner, call load before use
  BannerAd getBanner3() {
    final BannerAdListener listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) => print('Ad loaded.'),
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) => print('Ad opened.'),
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) => print('Ad closed.'),
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) => print('Ad impression.'),
    );
    final BannerAd myBanner = BannerAd(
      adUnitId: kTestBannerId,
      size: AdSize.mediumRectangle,
      request: const AdRequest(),
      listener: listener,
    );
    return myBanner;
  }
}
