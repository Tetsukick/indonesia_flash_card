import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

import '../config/color_config.dart';
import '../gen/assets.gen.dart';

class Utils {
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05];
    final swatch = <int, Color>{};
    final r = color.red;
    final g = color.green;
    final b = color.blue;

    for (var i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }

  static DateTime stringToDateTime(String stringDateTime) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.parse(stringDateTime);
  }

  static String dateTimeToString(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(dateTime);
  }

  static DateTime stringToDateTimeWithTime(String stringDateTime) {
    final formatter = DateFormat('yyyy-MM-dd hh:mm');
    return formatter.parse(stringDateTime);
  }

  static String dateTimeToStringWithTime(DateTime dateTime) {
    final formatter = DateFormat('yyyy-MM-dd hh:mm');
    return formatter.format(dateTime);
  }

  static String formatDateString(String stringDateTime) {
    return dateTimeToString(stringToDateTime(stringDateTime));
  }

  static Widget soundSettingSwitch({required bool value, required ValueChanged<bool> onToggle}) {
    return FlutterSwitch(
      height: 40,
      valueFontSize: 14,
      toggleSize: 32,
      value: value,
      showOnOff: true,
      activeIcon: Assets.png.soundOn64.image(height: 20, width: 20),
      inactiveIcon: Assets.png.soundOff64.image(height: 20, width: 20),
      activeColor: ColorConfig.primaryRed900,
      onToggle: onToggle,
    );
  }

  static Future<T> retry<T>({required int retries, required Future<T> aFuture}) async {
    try {
      return await aFuture;
    } catch (e) {
      if (retries > 1) {
        return Utils.retry(retries: retries - 1, aFuture: aFuture);
      }

      rethrow;
    }
  }

  static Future showSimpleAlert(BuildContext context, {required String title, String? content}) {
    return showPlatformDialog<void>(
      context: context,
      builder: (context) => BasicDialogAlert(
        title: Text(title),
        content: Visibility(
            visible: content != null,
            child: Text(content ?? ''),),
        actions: <Widget>[
          BasicDialogAction(
            title: const Text('OK'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  static Future<void> showUploadSuccessDialog(BuildContext context) async {
    unawaited(showGeneralDialog(
        context: context,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 300),
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (BuildContext context, Animation animation, Animation secondaryAnimation) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  Assets.lottie.thankYou,
                  height: 300,
                ),
              ],
            ),
          );
        },
    ));
    await Future<void>.delayed(const Duration(seconds: 3));
    Navigator.of(context).pop();
  }

  static bool rundomLottery({int totalNum = 3}) {
    final rand = math.Random();
    final lottery = rand.nextInt(totalNum);
    return lottery == 0;
  }
}