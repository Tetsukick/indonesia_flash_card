import 'package:googleapis/sheets/v4.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:http/http.dart' as http;
import 'package:indonesia_flash_card/config/credentials.dart';

class AuthRepo {
  Future<http.Client> getRegisteredHTTPClient() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    var scopes = [
      SheetsApi.spreadsheetsReadonlyScope,
      SheetsApi.driveReadonlyScope
    ];
    return await clientViaServiceAccount(accountCredentials, scopes);
  }
}
