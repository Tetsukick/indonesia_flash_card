import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:indonesia_flash_card/config/config.dart';

import 'utils.dart';

class Admob {
  static BannerAd smallBanner = BannerAd(
    adUnitId: Config.getAdUnitIdBanner(),
    size: AdSize.banner,
    request: AdRequest(),
    listener: Admob.bannerAdListener,
  );

  static BannerAdListener bannerAdListener = BannerAdListener(
    onAdFailedToLoad: (ad, error) {
      ad.dispose();
    },
  );

  static late InterstitialAd? interstitialAd;

  static Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: Config.getAdUnitIdInterstitial(),
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            interstitialAd = ad;
          },
          onAdFailedToLoad: (LoadAdError error) {
            loadInterstitialAd();
          },
        )
    );
  }

  static Future<void> showInterstitialAd() async {
    if (interstitialAd != null) {
      await interstitialAd!.show();
    }
  }
}

class AdmobBanner extends StatelessWidget {
  const AdmobBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Admob.smallBanner.load();
    return new AdWidget(ad: Admob.smallBanner);
  }
}
