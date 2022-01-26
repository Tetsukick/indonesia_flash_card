import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final formatter = DateFormat('yyyy-MM-dd HH:mm:ss');
    return formatter.parse(stringDateTime);
  }

  static DateTime stringToDateTimeWithTimeZone(String stringDateTime) {
    final formatter = DateFormat('yyyy-MM-ddTHH:mm:ssZ');
    return formatter.parse(stringDateTime);
  }

  static String dateTimeToString(DateTime dateTime) {
    final formatter = DateFormat('MM/dd HH:mm');
    return formatter.format(dateTime);
  }

  static String formatDateString(String stringDateTime) {
    return dateTimeToString(stringToDateTime(stringDateTime));
  }

  static String formatDateStringWithTimeZone(String stringDateTime) {
    return dateTimeToString(stringToDateTimeWithTimeZone(stringDateTime));
  }
}