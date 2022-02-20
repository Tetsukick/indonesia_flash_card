import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/model/tango_master.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';

import '../model/category.dart';
import '../model/level.dart';
import '../model/part_of_speech.dart';
import '../model/sort_type.dart';

final tangoListControllerProvider = StateNotifierProvider<TangoListController, TangoMaster>(
      (ref) => TangoListController(initialTangoMaster: TangoMaster()),
);

class TangoListController extends StateNotifier<TangoMaster> {
  TangoListController({required TangoMaster initialTangoMaster}) : super(initialTangoMaster);

  Future<List<TangoEntity>> getAllTangoList({required SheetRepo sheetRepo}) async {
    state = state..lesson.sheetRepo = sheetRepo;
    List<List<Object>>? entryList =
    await sheetRepo.getEntriesFromRange("A2:J1000");
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
    required SheetRepo sheetRepo,
    TangoCategory? category,
    PartOfSpeechEnum? partOfSpeech,
    LevelGroup? levelGroup,
    SortType? sortType
  }) async {
    state = state..lesson.sheetRepo = sheetRepo;
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(sheetRepo: sheetRepo);
    }
    List<TangoEntity> _filteredTangos = filterTangoList(category: category, partOfSpeech: partOfSpeech, levelGroup: levelGroup);
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
    state.dictionary.sortAndFilteredTangos = _filteredTangos;
    state = state..dictionary.sortAndFilteredTangos = _filteredTangos;

    return _filteredTangos;
  }

  Future<List<TangoEntity>> setLessonsData({
    required SheetRepo sheetRepo,
    TangoCategory? category,
    PartOfSpeechEnum? partOfSpeech,
    LevelGroup? levelGroup
  }) async {
    state = state..lesson.sheetRepo = sheetRepo;
    if (state.dictionary.allTangos == null || state.dictionary.allTangos.isEmpty) {
      await getAllTangoList(sheetRepo: sheetRepo);
    }
    List<TangoEntity> _filteredTangos = filterTangoList(category: category, partOfSpeech: partOfSpeech, levelGroup: levelGroup);
    if (_filteredTangos.length > 10) {
      _filteredTangos = _filteredTangos.getRange(0, 10).toList();
    }
    state = state..lesson.tangos = _filteredTangos;

    return _filteredTangos;
  }

  List<TangoEntity> filterTangoList({
    TangoCategory? category,
    PartOfSpeechEnum? partOfSpeech,
    LevelGroup? levelGroup,
  }) {
    final _tmpTangos = state.dictionary.allTangos;
    List<TangoEntity> _filteredTangos = _tmpTangos.where((element) {
      bool _filterCategory = category != null ? element.category == category.id : true;
      bool _filterPartOfSpeech = partOfSpeech != null ? element.partOfSpeech == partOfSpeech.id : true;
      bool _filterLevel = levelGroup != null ? levelGroup.range.any((e) => e == element.level) : true;
      return _filterCategory && _filterPartOfSpeech && _filterLevel;
    }).toList();
    return _filteredTangos;
  }

  Future<List<TangoEntity>> resetLessonsData() async {
    List<TangoEntity> _filteredTangos = filterTangoList(
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