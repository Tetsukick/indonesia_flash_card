import 'package:indonesia_flash_card/model/category.dart';
import 'package:indonesia_flash_card/model/frequency.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:indonesia_flash_card/model/level.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/translate_master.dart';

class TangoMaster {
  Dictionary dictionary = Dictionary();
  Lesson lesson = Lesson();
  TranslateMaster translateMaster = TranslateMaster();
  double totalAchievement = 0;
}

class Dictionary {
  List<TangoEntity> allTangos = [];
  List<TangoEntity> sortAndFilteredTangos = [];
  int count = 0;
}

class Lesson {
  LectureFolder? folder;
  TangoCategory? category;
  PartOfSpeechEnum? partOfSpeech;
  LevelGroup? levelGroup;
  FrequencyGroup? frequencyGroup;
  bool isBookmark = false;
  bool isNotRemembered = false;
  bool isTest = false;
  List<TangoEntity> tangos = [];
  List<QuizResult> quizResults = [];
}

class QuizResult {
  TangoEntity? entity;
  bool isCorrect = false;
  int answerTime = 15 * 1000;
}