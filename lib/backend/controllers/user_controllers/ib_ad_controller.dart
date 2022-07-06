import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// use this controller if you want to show inline ad in a list
class IbAdController extends GetxController {
  final BannerAd bannerAd;
  final isLoading = true.obs;

  IbAdController(this.bannerAd);

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    await Future.wait([
      bannerAd.dispose(),
      bannerAd.load(),
      Future.delayed(const Duration(milliseconds: 888))
    ]).then((value) => isLoading.value = false);
  }

  @override
  Future<void> onClose() async {
    super.onClose();
    await bannerAd.dispose();
  }
}
