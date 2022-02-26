import 'package:googleapis/sheets/v4.dart';
import 'package:indonesia_flash_card/utils/utils.dart';

import 'auth_repo.dart';
import 'package:http/http.dart' as http;

class SheetRepo {
  AuthRepo authRepo = AuthRepo();
  late SheetsApi sheetsApi;
  late http.Client client;
  late Future<void> init;
  final String spreadsheetId;

  SheetRepo(this.spreadsheetId) {
    init = initSheetRepo();
  }

  Future<List<List<Object?>>?> getEntriesFromRange(String range) async {
    await init;
    final result =
      await sheetsApi.spreadsheets.values.get(spreadsheetId, range);
    return result.values;
  }

  Future<void> initSheetRepo() async {
    final client = await Utils.retry(retries: 5, aFuture: authRepo.getRegisteredHTTPClient());
    sheetsApi = SheetsApi(client);
  }
}
