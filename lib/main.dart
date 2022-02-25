import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/screen/home_navigation.dart';
import 'package:indonesia_flash_card/screen/lesson_selector_screen.dart';
import 'package:indonesia_flash_card/utils/crash_reporter.dart';
import 'package:indonesia_flash_card/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runZonedGuarded(() async {
    await CrashReporter.instance.initialize();

    FlutterError.onError = (FlutterErrorDetails details) {
      CrashReporter.instance.report(details.exceptionAsString(), details.stack);
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

class FlushCardApp extends StatelessWidget {
  const FlushCardApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Utils.createMaterialColor(ColorConfig.primaryRed700),
      ),
      home: const HomeNavigation(),
    );
  }
}
