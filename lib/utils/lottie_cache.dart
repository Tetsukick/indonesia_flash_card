import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

final lottieCache = LottieCache();

class LottieCache {
  final Map<String, LottieComposition> _compositions = {};

  Future<void> add(String assetName) async {
    _compositions[assetName] = await AssetLottie(assetName).load();
  }

  Widget load(String assetName) {
    final composition = _compositions[assetName];
    if (composition != null) {
      return Lottie(composition: composition);
    } else {
      add(assetName);
      return Lottie.asset(assetName);
    }
  }
}