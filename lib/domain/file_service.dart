import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:googleapis/drive/v2.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:indonesia_flash_card/repository/gdrive_repo.dart';
import 'package:indonesia_flash_card/utils/logger.dart';

final fileControllerProvider = StateNotifierProvider<FileController, List<LectureFolder>>(
      (ref) => FileController(GDriveRepo(), initialLectures: List<LectureFolder>.empty()),
);

class FileController extends StateNotifier<List<LectureFolder>> {
  FileController(this._gDriveRepo, {required List<LectureFolder> initialLectures}) : super(initialLectures);
  final GDriveRepo _gDriveRepo;

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
    state = result;

    return result;
  }
}
