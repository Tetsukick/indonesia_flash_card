// Package imports:
import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigUtil {

  factory RemoteConfigUtil(){
    return _instance;
  }

  RemoteConfigUtil._internal();
  static final RemoteConfigUtil _instance = RemoteConfigUtil._internal();
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ),);
    await _remoteConfig.fetchAndActivate();
  }
  
  String getLatestDataUpdateDate() {
    return _remoteConfig.getString('last_tango_update_date');
  }

  String getSpreadsheetTargetRange() {
    return _remoteConfig.getString('spreadsheet_target_range');
  }

}
