import 'package:flutter/foundation.dart';

class Config {
  static const dictionarySpreadSheetName = '001 indonesian dictionary';
  static const dbName = 'app_database.db';
  static const adUnitIdAndroidBanner = kDebugMode ? 'ca-app-pub-3940256099942544/6300978111' : 'ca-app-pub-8604906384604870/6065497704';
  static const adUnitIdIosBanner = kDebugMode ? 'ca-app-pub-3940256099942544/2934735716' : 'ca-app-pub-8604906384604870/3596398411';
  static const adUnitIdAndroidInterstitial = kDebugMode ? 'ca-app-pub-3940256099942544/8691691433' : 'ca-app-pub-8604906384604870/4045826689';
  static const adUnitIdIosInterstitial = kDebugMode ? 'ca-app-pub-3940256099942544/5135589807' : 'ca-app-pub-8604906384604870/9323926290';

  static const apiKeyHeader = "x-api-key";
  static const contentTypeHeader = "Content-type";
  static const acceptHeader = "Accept";
  static const authorizationHeader = "Authorization";
}