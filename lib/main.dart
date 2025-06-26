// Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:ui';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

// Project imports:
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/screen/home_navigation.dart';
import 'package:indonesia_flash_card/utils/admob.dart';
import 'package:indonesia_flash_card/utils/analytics/firebase_analytics.dart';
import 'package:indonesia_flash_card/utils/crash_reporter.dart';
import 'package:indonesia_flash_card/utils/remote_config.dart';
import 'package:indonesia_flash_card/utils/utils.dart';

void main() async {
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    FirebaseAnalyticsUtils();
    Admob();
    await RemoteConfigUtil().init();
    await MobileAds.instance.initialize();
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    await CrashReporter.instance.initialize();

    FlutterError.onError = (errorDetails) {
      log(errorDetails.exceptionAsString(), stackTrace: errorDetails.stack);
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    runApp(
      const ProviderScope(
        child: FlushCardApp(),
      ),
    );
  }, (error, stack) {
    CrashReporter.instance.report(error, stack);
  });
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class FlushCardApp extends StatelessWidget {
  const FlushCardApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Utils.createMaterialColor(ColorConfig.primaryRed700),
        primaryColor: Utils.createMaterialColor(ColorConfig.primaryRed700),
      ),
      home: const HomeNavigation(),
      navigatorObservers: [routeObserver],
    );
  }
}
