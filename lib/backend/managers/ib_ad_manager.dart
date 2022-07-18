import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:icebr8k/frontend/ib_colors.dart';
import 'package:icebr8k/frontend/ib_utils.dart';

class IbAdManager {
  static const String kTestBannerIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String kTestRewardIdAndroid =
      'ca-app-pub-3940256099942544/5224354917';
  static const String kTestBannerIdIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String kTestRewardIdIos =
      'ca-app-pub-3940256099942544/1712485313';
  static const String kBanner1IdAndroid =
      'ca-app-pub-5061564569223287/1263768520';
  static const String kBanner2IdAndroid =
      'ca-app-pub-5061564569223287/9899708961';
  static const String kBanner3IdAndroid =
      'ca-app-pub-5061564569223287/4312603693';
  static const String kRewardIdAndroid =
      'ca-app-pub-5061564569223287/5965430867';

  //iOS
  static const String kBanner1IdiOS = 'ca-app-pub-5061564569223287/2424543622';
  static const String kBanner2IdiOS = 'ca-app-pub-5061564569223287/5541661558';
  static const String kBanner3IdiOS = 'ca-app-pub-5061564569223287/3166779657';
  static const String kRewardIdiOS = 'ca-app-pub-5061564569223287/5601371307';

  Future<void> showRewardAd(Function func) async {
    RewardedAd myAd;
    IbUtils().showSimpleSnackBar(
        msg: 'Loading Ad...', backgroundColor: IbColors.primaryColor);
    final adRequest = IbUtils().getCurrentIbUser() == null
        ? const AdRequest()
        : AdRequest(keywords: IbUtils().getCurrentIbUser()!.tags);

    await RewardedAd.load(
        adUnitId: kDebugMode
            ? GetPlatform.isAndroid
                ? kTestRewardIdAndroid
                : kTestRewardIdIos
            : GetPlatform.isAndroid
                ? kRewardIdAndroid
                : kRewardIdiOS,
        request: adRequest,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            bool isRewarded = false;
            myAd = ad;
            myAd.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (RewardedAd ad) =>
                  print('$ad onAdShowedFullScreenContent.'),
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                print('$ad onAdDismissedFullScreenContent.');
                ad.dispose();
                if (isRewarded) {
                  func();
                } else {
                  print('Reward is not granted yet');
                }
              },
              onAdFailedToShowFullScreenContent:
                  (RewardedAd ad, AdError error) {
                print('$ad onAdFailedToShowFullScreenContent: $error');
                ad.dispose();
              },
              onAdImpression: (RewardedAd ad) =>
                  print('$ad impression occurred.'),
            );
            myAd.show(onUserEarnedReward: (view, item) {
              print('Reward granted');
              isRewarded = true;
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ));
  }

  /// return banner 1
  BannerAd getBanner1({BannerAdListener? bannerAdListener}) {
    final adRequest = IbUtils().getCurrentIbUser() == null
        ? const AdRequest()
        : AdRequest(keywords: IbUtils().getCurrentIbUser()!.tags);
    bannerAdListener ??= BannerAdListener(
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
      adUnitId: kDebugMode
          ? GetPlatform.isAndroid
              ? kTestBannerIdAndroid
              : kTestBannerIdIos
          : GetPlatform.isAndroid
              ? kBanner1IdAndroid
              : kBanner1IdiOS,
      size: AdSize(height: 50, width: Get.width.toInt()),
      request: adRequest,
      listener: bannerAdListener,
    );
    return myBanner;
  }

  /// return  banner 2
  BannerAd getBanner2({BannerAdListener? bannerAdListener}) {
    final adRequest = IbUtils().getCurrentIbUser() == null
        ? const AdRequest()
        : AdRequest(keywords: IbUtils().getCurrentIbUser()!.tags);
    bannerAdListener ??= BannerAdListener(
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
      adUnitId: kDebugMode
          ? GetPlatform.isAndroid
              ? kTestBannerIdAndroid
              : kTestBannerIdIos
          : GetPlatform.isAndroid
              ? kBanner2IdAndroid
              : kBanner2IdiOS,
      size: AdSize(height: 50, width: Get.width.toInt()),
      request: adRequest,
      listener: bannerAdListener,
    );
    return myBanner;
  }

  /// return medium size banner, call load before use
  BannerAd getBanner3({BannerAdListener? bannerAdListener}) {
    final adRequest = IbUtils().getCurrentIbUser() == null
        ? const AdRequest()
        : AdRequest(keywords: IbUtils().getCurrentIbUser()!.tags);
    bannerAdListener ??= BannerAdListener(
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
      adUnitId: kDebugMode
          ? GetPlatform.isAndroid
              ? kTestBannerIdAndroid
              : kTestBannerIdIos
          : GetPlatform.isAndroid
              ? kBanner3IdAndroid
              : kBanner3IdiOS,
      size: AdSize.mediumRectangle,
      request: adRequest,
      listener: bannerAdListener,
    );
    return myBanner;
  }
}
