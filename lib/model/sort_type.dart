enum SortType {
  indonesian,
  indonesianReverse,
  level,
  levelReverse,
}

extension SortTypeExt on SortType {
  String get title {
    switch (this) {
      case SortType.indonesian:
        return 'A→Z 昇順';
      case SortType.indonesianReverse:
        return 'Z→A 降順';
      case SortType.level:
        return 'レベル昇順';
      case SortType.levelReverse:
        return 'レベル降順';
    }
  }
}