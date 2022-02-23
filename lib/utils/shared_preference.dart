import 'package:shared_preferences/shared_preferences.dart';

enum PreferenceKey {
  isSoundOn
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
}