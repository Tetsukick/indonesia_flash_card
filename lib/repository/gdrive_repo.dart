import 'package:googleapis/drive/v2.dart';
import 'package:indonesia_flash_card/utils/logger.dart';
import 'auth_repo.dart';

class GDriveRepo {

  GDriveRepo() {
    init = initSheetRepo();
  }
  AuthRepo authRepo = AuthRepo();
  late DriveApi driveApi;
  late Future<void> init;

  Future<List<File>> getFilesAndFolders() async {
    await init;
    try {
      final result = await driveApi.files.list();
      logger.d('getFilesAndFolders result: ${result.items}');
      final files = result.items;
      if (files == null) {
        throw UnsupportedError('No files found');
      }
      return files;
    } catch (e) {
      logger.d(e);
      await Future.delayed(const Duration(seconds: 3));
      return getFilesAndFolders();
    }
  }

  Future<void> initSheetRepo() async {
    final client = await authRepo.getRegisteredHTTPClient();
    driveApi = DriveApi(client);
  }
}
