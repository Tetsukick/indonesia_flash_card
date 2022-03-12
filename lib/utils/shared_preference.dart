import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  isSoundOn,
  lastTestDate,
}

extension PreferenceKeyEx on PreferenceKey {
  String get keyString => this.name;

  Future<bool> setBool(bool value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setBool(keyString, value);
  }

  Future<bool> getBool() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(keyString)) {
      return (await pref.getBool(keyString)) ?? false;
    } else {
      return false;
    }
  }

  Future<bool> setString(String value) async {
    final pref = await SharedPreferences.getInstance();
    return pref.setString(keyString, value);
  }

  Future<String?> getString() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.containsKey(keyString)) {
      return pref.getString(keyString);
    } else {
      return null;
    }
  }
}