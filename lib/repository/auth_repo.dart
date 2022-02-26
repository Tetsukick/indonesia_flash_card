import 'dart:io';

import 'package:googleapis/sheets/v4.dart';
import "package:googleapis_auth/auth_io.dart";
import 'package:http/http.dart' as http;
import 'package:indonesia_flash_card/config/credentials.dart';

class AuthRepo {
  static http.Client? client;

  Future<http.Client> getRegisteredHTTPClient() async {
    final accountCredentials = ServiceAccountCredentials.fromJson(credentials);
    var scopes = [
      SheetsApi.spreadsheetsReadonlyScope,
      SheetsApi.driveReadonlyScope
    ];
    if (AuthRepo.client == null) {
      AuthRepo.client = await clientViaServiceAccount(accountCredentials, scopes);
    }
    return AuthRepo.client!;
  }
}