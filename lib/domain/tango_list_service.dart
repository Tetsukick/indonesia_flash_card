import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:indonesia_flash_card/config/config.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:indonesia_flash_card/model/tango_master.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';

import '../model/category.dart';
import '../model/floor_database/database.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/level.dart';
import '../model/part_of_speech.dart';
import '../model/sort_type.dart';

final tangoListControllerProvider = StateNotifierProvider<TangoListController, TangoMaster>(
      (ref) => TangoListController(initialTangoMaster: TangoMaster()),
);

class TangoListController extends StateNotifier<TangoMaster> {
  TangoListController({required TangoMaster initialTangoMaster}) : super(initialTangoMaster);

  Future<List<TangoEntity>> getAllTangoList({required LectureFolder folder}) async {
    state = state..lesson.folder = folder;
    final sheetRepo = SheetRepo(folder.spreadsheets.firstWhere((element) => element.name == Config.dictionarySpreadSheetName).id);
    List<List<Object?>>? entryList = await sheetRepo.getEntriesFromRange("A2:J501");
    if (entryList == null) {
      throw UnsupportedError("There are no questions nor answers.");
    }

    List<TangoEntity> tangoList = [];

    for (var element in entryList) {
      if (element.isEmpty) continue;
      if (element.length == 1) continue;

      if (element.length < 9) {
        throw UnsupportedError("The csv must have exactly 2 columns");
      }

      TangoEntity tmpTango = TangoEntity()
        ..id = int.parse(element[0].toString().trim())
        ..indonesian = element[1].toString().trim()
        ..japanese = element[2].toString().trim()
        ..english = element[3].toString().trim()
        ..description = element[4].toString().trim()
        ..example = element[5].toString().trim()
        ..exampleJp = element[6].toString().trim()
        ..level = int.parse(element[7].toString().trim())
        ..partOfSpeech = int.parse(element[8].toString().trim());

      if (element.length == 10) {
        tmpTango.category = int.parse(element[9].toString().trim());
      }

      tangoList.add(tmpTango);
    }
    tangoList.sort((a, b) {
      return a.indonesian!.toLowerCase().compareTo(b.indonesian!.toLowerCase());
    });
    state = state
      ..dictionary.allTangos = tangoList
      ..dictionary.sortAndFilteredTangos = tangoList;

    return tangoList;
  }

  Future<List<TangoEntity>> getSortAndFilteredTangoList({
    TangoCategory? category,
    PartOfSpeechEnum? partOfSpeech,
    LevelGroup? levelGroup,
    WordStatusType? wordStatusType,
    SortType? sortType
  }) async {
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(folder: state.lesson.folder!);
    }
    List<TangoEntity> _filteredTangos = await filterTangoList(category: category, partOfSpeech: partOfSpeech, levelGroup: levelGroup, wordStatusType: wordStatusType);
    if (sortType != null) {
      if (sortType == SortType.indonesian || sortType == SortType.indonesianReverse) {
        _filteredTangos.sort((a, b) {
          return a.indonesian!.toLowerCase().compareTo(b.indonesian!.toLowerCase());
        });
        if (sortType == SortType.indonesianReverse) {
          _filteredTangos = _filteredTangos.reversed.toList();
        }
      } else if (sortType == SortType.level || sortType == SortType.levelReverse) {
        _filteredTangos.sort((a, b) {
          return a.level!.compareTo(b.level!);
        });
        if (sortType == SortType.levelReverse) {
          _filteredTangos = _filteredTangos.reversed.toList();
        }
      }
    }
    state = state..dictionary.sortAndFilteredTangos = _filteredTangos;

    return _filteredTangos;
  }

  Future<List<TangoEntity>> setLessonsData({
    TangoCategory? category,
    PartOfSpeechEnum? partOfSpeech,
    LevelGroup? levelGroup
  }) async {
    state = state
      ..lesson.category = category
      ..lesson.partOfSpeech = partOfSpeech
      ..lesson.levelGroup = levelGroup
      ..lesson.isBookmark = false;
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(folder: state.lesson.folder!);
    }
    List<TangoEntity> _filteredTangos = await filterTangoList(category: category, partOfSpeech: partOfSpeech, levelGroup: levelGroup);
    _filteredTangos.shuffle();
    if (_filteredTangos.length > 10) {
      final wordStatusList = await getAllWordStatus();
      _filteredTangos.sort((a, b) {
        if (!(wordStatusList.any((element) => element.wordId == b.id))) {
          return 1;
        } else if (wordStatusList.firstWhere((element) => element.wordId == b.id).status == WordStatusType.notRemembered.id) {
          return 0;
        } else {
          return -1;
        }
      });
      _filteredTangos = _filteredTangos.getRange(0, 10).toList();
    }
    _filteredTangos.shuffle();
    state = state..lesson.tangos = _filteredTangos;

    return _filteredTangos;
  }

  Future<List<TangoEntity>> setBookmarkLessonsData() async {
    state = state..lesson.isBookmark = true;
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(folder: state.lesson.folder!);
    }
    List<TangoEntity> _filteredTangos = await filterTangoList(isBookmark: true);
    _filteredTangos.shuffle();
    state = state..lesson.tangos = _filteredTangos;

    return _filteredTangos;
  }

  Future<List<WordStatus>> getAllWordStatus() async {
    final database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();

    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findAllWordStatus();
    return wordStatus;
  }

  Future<List<TangoEntity>> filterTangoList({
    TangoCategory? category,
    PartOfSpeechEnum? partOfSpeech,
    LevelGroup? levelGroup,
    WordStatusType? wordStatusType,
    bool isBookmark = false
  }) async {
    final _tmpTangos = state.dictionary.allTangos;
    List<TangoEntity> _filteredTangos = _tmpTangos.where((element) {
      bool _filterCategory = category != null ? element.category == category.id : true;
      bool _filterPartOfSpeech = partOfSpeech != null ? element.partOfSpeech == partOfSpeech.id : true;
      bool _filterLevel = levelGroup != null ? levelGroup.range.any((e) => e == element.level) : true;
      return _filterCategory && _filterPartOfSpeech && _filterLevel;
    }).toList();
    if (wordStatusType != null) {
      final wordStatusList = await getAllWordStatus();
      _filteredTangos = _filteredTangos.where((element) {
          final targetWordStatus = wordStatusList.firstWhereOrNull((e) {
            return e.wordId == element.id;
          });
          if (targetWordStatus == null) {
            return wordStatusType == WordStatusType.notLearned;
          } else {
            return targetWordStatus.status == wordStatusType.id;
          }
        }).toList();
    }
    if (isBookmark) {
      final wordStatusList = await getAllWordStatus();
      _filteredTangos = _filteredTangos.where((element) {
        final targetWordStatus = wordStatusList.firstWhereOrNull((e) {
          return e.wordId == element.id;
        });
        return targetWordStatus != null && targetWordStatus.isBookmarked;
      }).toList();
    }
    return _filteredTangos;
  }

  Future<List<TangoEntity>> resetLessonsData() async {
    if (state.lesson.isBookmark) {
      List<TangoEntity> _filteredTangos = state.lesson.tangos;
      _filteredTangos.shuffle();
      return _filteredTangos;
    }
    List<TangoEntity> _filteredTangos = await filterTangoList(
        category: state.lesson.category,
        partOfSpeech: state.lesson.partOfSpeech,
        levelGroup: state.lesson.levelGroup);
    _filteredTangos.shuffle();
    if (_filteredTangos.length > 10) {
      _filteredTangos = _filteredTangos.getRange(0, 10).toList();
    }
    state = state..lesson.tangos = _filteredTangos;

    return _filteredTangos;
  }
}