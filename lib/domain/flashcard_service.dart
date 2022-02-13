import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';

typedef QuestionString = String;
typedef AnswerString = String;
typedef HintString = String;
typedef SolutionString = String;

final flashCardControllerProvider = StateNotifierProvider<FlashCardController, List<TangoEntity>>(
      (ref) => FlashCardController(initialTangos: List<TangoEntity>.empty()),
);

class FlashCardController extends StateNotifier<List<TangoEntity>> {
  FlashCardController({required List<TangoEntity> initialTangos}) : super(initialTangos);

  Future<List<TangoEntity>> getQuestionsAndAnswers(SheetRepo sheetRepo) async {
    List<List<Object>>? entryList =
    await sheetRepo.getEntriesFromRange("A2:J1000");
    if (entryList == null) {
      throw UnsupportedError("There are no questions nor answers.");
    }

    List<TangoEntity> questionsAndAnswers = [];

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

      questionsAndAnswers.add(tmpTango);
    }
    final _tmpQuestionsAndAnswers = questionsAndAnswers;
    _tmpQuestionsAndAnswers.shuffle();
    state = _tmpQuestionsAndAnswers;

    return questionsAndAnswers;
  }
}
