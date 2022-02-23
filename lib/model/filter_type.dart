enum FilterType {
  wordStatus,
  levelGroup,
  category
}

extension FilterTypeExt on FilterType {
  String get title {
    switch (this) {
      case FilterType.wordStatus:
        return '単語ステータス';
      case FilterType.levelGroup:
        return 'レベル';
      case FilterType.category:
        return 'カテゴリー';
    }
  }
}