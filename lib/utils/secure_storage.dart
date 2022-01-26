import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  void saveUserId(String userId) async {
    await secureStorage.write(key: 'userId', value: userId);
  }

  Future<String> getUserId() async {
    final stringValue = await secureStorage.read(key: 'userId');
    return stringValue ?? '';
  }

  void logout() {
    secureStorage.delete(key: 'userId');
  }
}