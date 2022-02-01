import 'package:googleapis/drive/v2.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:indonesia_flash_card/repository/gdrive_repo.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

class FilesService {
  final GDriveRepo _gDriveRepo;

  FilesService(this._gDriveRepo);

  Future<List<LectureFolder>> getPossibleLectures() async {
    List<File> filesAndFolders = await _gDriveRepo.getFilesAndFolders();
    logger.d('file and folders: ${filesAndFolders}');

    final spreadsheets = filesAndFolders
        .where((element) => element.mimeType?.contains("spreadsheet") ?? false)
        .toList();

    List<LectureFolder> result = [LectureFolder('bahasa indonesia', [])];

    for (var spreadsheet in spreadsheets) {
      final lectureFolder = result[0];

      lectureFolder.spreadsheets.add(
        LectureInformation(spreadsheet.title ?? "", spreadsheet.id ?? ""),
      );
    }

    return result;
  }
}
