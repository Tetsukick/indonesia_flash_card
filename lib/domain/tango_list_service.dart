import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:indonesia_flash_card/config/config.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:indonesia_flash_card/model/tango_master.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';
import 'package:indonesia_flash_card/repository/translate_repo.dart';
import 'package:indonesia_flash_card/utils/logger.dart';
import 'package:indonesia_flash_card/utils/utils.dart';

import '../model/category.dart';
import '../model/floor_database/database.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/level.dart';
import '../model/part_of_speech.dart';
import '../model/sort_type.dart';
import '../model/translate_response_entity.dart';

final tangoListControllerProvider = StateNotifierProvider<TangoListController, TangoMaster>(
      (ref) => TangoListController(initialTangoMaster: TangoMaster()),
);

class TangoListController extends StateNotifier<TangoMaster> {
  TangoListController({required TangoMaster initialTangoMaster}) : super(initialTangoMaster);

  Future<List<TangoEntity>> getAllTangoList({required LectureFolder folder}) async {
    state = state..lesson.folder = folder;

    final sheetRepos = folder.spreadsheets.where((element) => element.name.contains(Config.dictionarySpreadSheetName)).map((e) => SheetRepo(e.id));
    List<List<Object?>> entryList = [];
    await Future.forEach<SheetRepo>(sheetRepos, (element) async {
      List<List<Object?>>? _entryList = await Utils.retry(retries: 3, aFuture: element.getEntriesFromRange("A2:L3000"));
      logger.d('SheetId ${element.spreadsheetId}: ${_entryList?.length ?? 0}');
      if (_entryList != null) {
        entryList.addAll(_entryList);
        logger.d('entryList: ${entryList.length}');
      }
    });

    logger.d('entryList: ${entryList.length}');
    if (entryList.isEmpty) {
      throw UnsupportedError("There are no questions nor answers.");
    }

    List<TangoEntity> tangoList = [];

    for (var element in entryList) {
      if (element.isEmpty) continue;
      if (element[1].toString().trim() == ''
          || element[2].toString().trim() == '') {
        continue;
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

      if (element.length >= 10) {
        tmpTango.category = element[9].toString().trim() == '' ? null : int.parse(element[9].toString().trim());
        tmpTango.frequency = int.parse(element[10].toString().trim());
        tmpTango.rankFrequency = int.parse(element[11].toString().trim());
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
    initializeLessonState();
    state = state
      ..lesson.category = category
      ..lesson.partOfSpeech = partOfSpeech
      ..lesson.levelGroup = levelGroup;
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(folder: state.lesson.folder!);
    }
    List<TangoEntity> _filteredTangos = await filterTangoList(category: category, partOfSpeech: partOfSpeech, levelGroup: levelGroup);
    _filteredTangos.shuffle();
    if (_filteredTangos.length > 10) {
      final wordStatusList = await getAllWordStatus();
      _filteredTangos.sort((a, b) {
        if (!(wordStatusList.any((element) => element.wordId == b.id))) {
          return 100;
        } else {
          return getTargetStatusId(wordStatusList, a.id!)
              .compareTo(getTargetStatusId(wordStatusList, b.id!));
        }
      });
      _filteredTangos = _filteredTangos.getRange(0, 10).toList();
    }
    _filteredTangos.shuffle();
    state = state..lesson.tangos = _filteredTangos;

    return _filteredTangos;
  }

  int getTargetStatusId(List<WordStatus> wordStatusList, int wordId) {
    return wordStatusList
        .firstWhereOrNull((element) => element.wordId == wordId)?.status ?? -1;
  }

  void addQuizResult(QuizResult result) {
    state = state..lesson.quizResults.add(result);
  }

  Future<List<TangoEntity>> setBookmarkLessonsData() async {
    initializeLessonState();
    state = state
      ..lesson.isBookmark = true;
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(folder: state.lesson.folder!);
    }
    List<TangoEntity> _filteredTangos = await filterTangoList(isBookmark: true);
    _filteredTangos.shuffle();
    state = state..lesson.tangos = _filteredTangos;

    return _filteredTangos;
  }

  Future<List<TangoEntity>> setNotRememberedTangoLessonsData() async {
    initializeLessonState();
    state = state
      ..lesson.isNotRemembered = true;
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(folder: state.lesson.folder!);
    }
    List<TangoEntity> _filteredTangos = await filterTangoList(isNotRemembered: true);
    _filteredTangos.shuffle();
    if (_filteredTangos.length > 10) {
      _filteredTangos = _filteredTangos.getRange(0, 10).toList();
    }
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
    bool isBookmark = false,
    bool isNotRemembered = false
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
    if (isNotRemembered) {
      final wordStatusList = await getAllWordStatus();
      _filteredTangos = _filteredTangos.where((element) {
        final targetWordStatus = wordStatusList.firstWhereOrNull((e) {
          return e.wordId == element.id;
        });
        return targetWordStatus != null && targetWordStatus.status == WordStatusType.notRemembered.id;
      }).toList();
    }
    return _filteredTangos;
  }

  Future<List<TangoEntity>> resetLessonsData() async {
    state = state..lesson.quizResults = [];
    if (state.lesson.isBookmark) {
      List<TangoEntity> _filteredTangos = state.lesson.tangos;
      _filteredTangos.shuffle();
      return _filteredTangos;
    } else if (state.lesson.isNotRemembered) {
      return setNotRememberedTangoLessonsData();
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

  Future<List<TangoEntity>> setTestData() async {
    initializeLessonState();
    state = state
      ..lesson.isTest = true;
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(folder: state.lesson.folder!);
    }
    List<TangoEntity> _filteredTangos = [];
    await Future.forEach(LevelGroup.values, (element) async {
      final targetLevelGroup = element as LevelGroup;
      var _tempeTangos = await filterTangoList(levelGroup: targetLevelGroup);
      _tempeTangos.shuffle();
      _tempeTangos = _tempeTangos.getRange(0, 4).toList();
      _filteredTangos.addAll(_tempeTangos);
    });
    _filteredTangos.shuffle();
    state = state..lesson.tangos = _filteredTangos;

    return _filteredTangos;
  }

  void initializeLessonState() {
    state = state
      ..lesson.category = null
      ..lesson.partOfSpeech = null
      ..lesson.levelGroup = null
      ..lesson.isBookmark = false
      ..lesson.isNotRemembered = false
      ..lesson.isTest = false
      ..lesson.quizResults = [];
  }

  Future<TranslateResponseEntity> translate(String origin, {bool isIndonesianToJapanese = true}) async {
    final response = await TranslateRepo().translate(origin, isIndonesianToJapanese: isIndonesianToJapanese);
    state = state..translateMaster.translateApiResponse = response;
    return response;
  }

  Future<List<TangoEntity>> searchIncludeWords(String value) async {
    List<TangoEntity> includedWords = [];
    final wordList = value.split(' ');
    final baseSearchLength = 3;
    for (var i = 0; i < wordList.length; i++) {
      final remainCount = [baseSearchLength, wordList.length - i].reduce(min);
      var searchText = '';
      for (var j = 0; j < remainCount; j++) {
        if (j>0) {
          searchText = searchText + ' ';
        }
        searchText = searchText + wordList[i + j];
        includedWords.addAll(await search(searchText));
      }
    }
    state = state..translateMaster.includedTangos = includedWords;
    return includedWords;
  }

  Future<List<TangoEntity>> search(String search) async {
    final allTangoList = state.dictionary.allTangos;
    var searchTangos = allTangoList
        .where((tango) {
          return tango.indonesian!.toLowerCase() == search.toLowerCase();
        }).toList();
    return searchTangos;
  }
}