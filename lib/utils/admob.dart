import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:indonesia_flash_card/config/config.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

import 'utils.dart';

class Admob {

  factory Admob() {
    _instance._loadInterstitialAd();
    return _instance;
  }

  Admob._internal();
  static final Admob _instance = Admob._internal();

  InterstitialAd? interstitialAd;

  Future<void> _loadInterstitialAd() async {
    if (_instance.interstitialAd == null) {
      await InterstitialAd.load(
          adUnitId: Config.getAdUnitIdInterstitial(),
          request: const AdRequest(),
          adLoadCallback: InterstitialAdLoadCallback(
            onAdLoaded: (InterstitialAd ad) {
              _instance.interstitialAd = ad;
            },
            onAdFailedToLoad: (LoadAdError error) {
              logger.d(error);
            },
          )
      );
    }
  }

  Future<void> showInterstitialAd() async {
    if (interstitialAd != null) {
      await interstitialAd!.show();
      await _loadInterstitialAd();
    }
  }
}

// class AdmobBanner extends StatelessWidget {
//   AdmobBanner({Key? key}) : super(key: key);
//   late BannerAd smallBanner;
//
//   final BannerAdListener bannerAdListener = BannerAdListener(
//     onAdFailedToLoad: (ad, error) {
//       ad.dispose();
//     },
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     smallBanner = BannerAd(
//       adUnitId: Config.getAdUnitIdBanner(),
//       size: AdSize.banner,
//       request: const AdRequest(),
//       listener: bannerAdListener,
//     );
//     return AdWidget(ad: smallBanner);
//   }
// }
