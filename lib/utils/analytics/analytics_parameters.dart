enum AnalyticsScreen {
  lectureSelector,
  dictionary,
  dictionaryDetail,
  menu,
  flushCard,
  lessonComp,
  quiz,
  translation
}

extension AnalyticsScreenExt on AnalyticsScreen {
  String get name => toString().split('.').last;
}

enum AnalyticsActionType {
  tap,
  input
}

extension AnalyticsActionTypeExt on AnalyticsActionType {
  String get name => toString().split('.').last;
}

enum LectureSelectorItem {
  bookmarkLesson,
  lessonCard,
  todayTest,
}

extension LectureSelectorItemExt on LectureSelectorItem {
  AnalyticsScreen get screen => AnalyticsScreen.lectureSelector;
  String get shortName => toString().split('.').last;
  String get name => '${screen.name}_$shortName';
  String get screenId => screen.index.toString().padLeft(2, '0');
  String get id =>
      '$screenId${(index + 1).toString().padLeft(2, '0')}';
}

enum DictionaryItem {
  search,
  dictionaryItem,
  showSortFilter,
  filter,
  sort,
}

extension DictionaryItemExt on DictionaryItem {
  AnalyticsScreen get screen => AnalyticsScreen.dictionary;
  String get shortName => toString().split('.').last;
  String get name => '${screen.name}_$shortName';
  String get screenId => screen.index.toString().padLeft(2, '0');
  String get id =>
      '$screenId${(index + 1).toString().padLeft(2, '0')}';
}

enum DictionaryDetailItem {
  close,
  sound,
  bookmark,
}

extension DictionaryDetailItemExt on DictionaryDetailItem {
  AnalyticsScreen get screen => AnalyticsScreen.dictionaryDetail;
  String get shortName => toString().split('.').last;
  String get name => '${screen.name}_$shortName';
  String get screenId => screen.index.toString().padLeft(2, '0');
  String get id =>
      '$screenId${(index + 1).toString().padLeft(2, '0')}';
}

enum MenuAnalyticsItem {
  soundSetting,
  addTango,
  privacyPolicy,
  feedback,
  developer,
  license
}

extension MenuAnalyticsItemExt on MenuAnalyticsItem {
  AnalyticsScreen get screen => AnalyticsScreen.menu;
  String get shortName => toString().split('.').last;
  String get name => '${screen.name}_$shortName';
  String get screenId => screen.index.toString().padLeft(2, '0');
  String get id =>
      '$screenId${(index + 1).toString().padLeft(2, '0')}';
}

enum FlushCardItem {
  back,
  sound,
  bookmark,
  openCard,
  remember,
  unknown
}

extension FlushCardItemExt on FlushCardItem {
  AnalyticsScreen get screen => AnalyticsScreen.flushCard;
  String get shortName => toString().split('.').last;
  String get name => '${screen.name}_$shortName';
  String get screenId => screen.index.toString().padLeft(2, '0');
  String get id =>
      '$screenId${(index + 1).toString().padLeft(2, '0')}';
}

enum LessonCompItem {
  tangoCard,
  continueBtn,
  backTop
}

extension LessonCompItemExt on LessonCompItem {
  AnalyticsScreen get screen => AnalyticsScreen.lessonComp;
  String get shortName => toString().split('.').last;
  String get name => '${screen.name}_$shortName';
  String get screenId => screen.index.toString().padLeft(2, '0');
  String get id =>
      '$screenId${(index + 1).toString().padLeft(2, '0')}';
}