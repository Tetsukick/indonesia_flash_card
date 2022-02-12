import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';

typedef QuestionString = String;
typedef AnswerString = String;
typedef HintString = String;
typedef SolutionString = String;

final flashCardControllerProvider = StateNotifierProvider<FlashCardController, List<MapEntry<String, String>>>(
      (ref) => FlashCardController(initialQuestions: List<MapEntry<String, String>>.empty()),
);

class FlashCardController extends StateNotifier<List<MapEntry<String, String>>> {
  FlashCardController({required List<MapEntry<String, String>> initialQuestions}) : super(initialQuestions);

  Future<Map<QuestionString, AnswerString>> getQuestionsAndAnswers(SheetRepo sheetRepo) async {
    List<List<Object>>? entryList =
    await sheetRepo.getEntriesFromRange("B2:C1000");
    if (entryList == null) {
      throw UnsupportedError("There are no questions nor answers.");
    }

    Map<QuestionString, AnswerString> questionsAndAnswers = {};

    for (var element in entryList) {
      if (element.isEmpty) continue;

      if (element.length != 2) {
        throw UnsupportedError("The csv must have exactly 2 columns");
      }

      questionsAndAnswers.putIfAbsent(
        element[0].toString().trim(),
            () => element[1].toString().trim(),
      );
    }
    final _tmpQuestionsAndAnswers = questionsAndAnswers.entries.toList();
    _tmpQuestionsAndAnswers.shuffle();
    state = _tmpQuestionsAndAnswers;

    return questionsAndAnswers;
  }
}
