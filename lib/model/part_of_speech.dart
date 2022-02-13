enum PartOfSpeech {
  noun,
  verbs,
  adjectives,
  conjunctions,
  prepositions,
  pronouns,
  adverbs,
  interrogatives,
  numerals,
  auxiliaryVerbs,
  other
}

extension PartOfSpeechExt on PartOfSpeech {
  int get id => index + 1;

  String get title {
    switch (this) {
      case PartOfSpeech.noun:
        return '名詞';
      case PartOfSpeech.verbs:
        return '動詞';
      case PartOfSpeech.adjectives:
        return '形容詞';
      case PartOfSpeech.conjunctions:
        return '接続詞';
      case PartOfSpeech.prepositions:
        return '前置詞';
      case PartOfSpeech.pronouns:
        return '代名詞';
      case PartOfSpeech.adverbs:
        return '副詞';
      case PartOfSpeech.interrogatives:
        return '疑問詞';
      case PartOfSpeech.numerals:
        return '数詞';
      case PartOfSpeech.auxiliaryVerbs:
        return '助動詞';
      default:
        return 'その他';
    }
  }

  static PartOfSpeech intToPartOfSpeech({required int value}) {
    switch (value) {
      case 1:
        return PartOfSpeech.noun;
      case 2:
        return PartOfSpeech.verbs;
      case 3:
        return PartOfSpeech.adjectives;
      case 4:
        return PartOfSpeech.conjunctions;
      case 5:
        return PartOfSpeech.prepositions;
      case 6:
        return PartOfSpeech.pronouns;
      case 7:
        return PartOfSpeech.adverbs;
      case 8:
        return PartOfSpeech.interrogatives;
      case 9:
        return PartOfSpeech.numerals;
      case 10:
        return PartOfSpeech.auxiliaryVerbs;
      default:
        return PartOfSpeech.other;
    }
  }
}