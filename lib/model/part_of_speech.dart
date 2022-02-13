enum PartOfSpeechEnum {
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

extension PartOfSpeechExt on PartOfSpeechEnum {
  int get id => index + 1;

  String get title {
    switch (this) {
      case PartOfSpeechEnum.noun:
        return '名詞';
      case PartOfSpeechEnum.verbs:
        return '動詞';
      case PartOfSpeechEnum.adjectives:
        return '形容詞';
      case PartOfSpeechEnum.conjunctions:
        return '接続詞';
      case PartOfSpeechEnum.prepositions:
        return '前置詞';
      case PartOfSpeechEnum.pronouns:
        return '代名詞';
      case PartOfSpeechEnum.adverbs:
        return '副詞';
      case PartOfSpeechEnum.interrogatives:
        return '疑問詞';
      case PartOfSpeechEnum.numerals:
        return '数詞';
      case PartOfSpeechEnum.auxiliaryVerbs:
        return '助動詞';
      default:
        return 'その他';
    }
  }

  static PartOfSpeechEnum intToPartOfSpeech({required int value}) {
    switch (value) {
      case 1:
        return PartOfSpeechEnum.noun;
      case 2:
        return PartOfSpeechEnum.verbs;
      case 3:
        return PartOfSpeechEnum.adjectives;
      case 4:
        return PartOfSpeechEnum.conjunctions;
      case 5:
        return PartOfSpeechEnum.prepositions;
      case 6:
        return PartOfSpeechEnum.pronouns;
      case 7:
        return PartOfSpeechEnum.adverbs;
      case 8:
        return PartOfSpeechEnum.interrogatives;
      case 9:
        return PartOfSpeechEnum.numerals;
      case 10:
        return PartOfSpeechEnum.auxiliaryVerbs;
      default:
        return PartOfSpeechEnum.other;
    }
  }
}