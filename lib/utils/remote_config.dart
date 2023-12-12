import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:indonesia_flash_card/utils/utils.dart';

class RemoteConfigUtil {
  static final RemoteConfigUtil _instance = RemoteConfigUtil._internal();
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  factory RemoteConfigUtil(){
    return _instance;
  }

  RemoteConfigUtil._internal();

  Future<void> init() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await _remoteConfig.fetchAndActivate();
  }
  
  String getLatestDataUpdateDate() {
    return _remoteConfig.getString('last_tango_update_date');
  }

}
