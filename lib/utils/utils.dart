import 'package:flutter/material.dart';
import 'package:flutter_dialogs/flutter_dialogs.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:intl/intl.dart';

import '../config/color_config.dart';
import '../gen/assets.gen.dart';

class Utils {
  static MaterialColor createMaterialColor(Color color) {
    List<double> strengths = <double>[.05];
    final swatch = <int, Color>{};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    strengths.forEach((strength) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    });
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

  static String formatDateString(String stringDateTime) {
    return dateTimeToString(stringToDateTime(stringDateTime));
  }

  static Widget soundSettingSwitch({required bool value, required ValueChanged<bool> onToggle}) {
    return FlutterSwitch(
      width: 70.0,
      height: 40.0,
      valueFontSize: 14.0,
      toggleSize: 32.0,
      value: value,
      borderRadius: 20.0,
      padding: 4.0,
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
            child: Text(content ?? '')),
        actions: <Widget>[
          BasicDialogAction(
            title: Text("OK"),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}