import 'package:indonesia_flash_card/model/category.dart';
import 'package:indonesia_flash_card/model/level.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';

class TangoMaster {
  Dictionary dictionary = Dictionary();
  Lesson lesson = Lesson();
}

class Dictionary {
  List<TangoEntity> allTangos = [];
  List<TangoEntity> sortAndFilteredTangos = [];
}

class Lesson {
  SheetRepo? sheetRepo;
  TangoCategory? category;
  PartOfSpeechEnum? partOfSpeech;
  LevelGroup? levelGroup;
  List<TangoEntity> tangos = [];
}