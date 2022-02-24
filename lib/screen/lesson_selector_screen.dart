import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/category.dart';
import 'package:indonesia_flash_card/model/floor_entity/activity.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/model/level.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/shared_preference.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';
import 'package:lottie/lottie.dart';

import '../config/config.dart';
import '../model/floor_database/database.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import 'flush_card_screen.dart';

class LessonSelectorScreen extends ConsumerStatefulWidget {
  const LessonSelectorScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LessonSelectorScreen> createState() => _LessonSelectorScreenState();

  static void navigateTo(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const LessonSelectorScreen();
      },
    ));
  }
}

class _LessonSelectorScreenState extends ConsumerState<LessonSelectorScreen> {
  late Future<List<LectureFolder>> getPossibleLectures;
  final itemCardWidth = 200.0;
  final itemCardHeight = 160.0;
  int _currentLevelIndex = 0;
  final CarouselController _levelCarouselController = CarouselController();
  int _currentCategoryIndex = 0;
  final CarouselController _categoryCarouselController = CarouselController();
  int _currentPartOfSpeechIndex = 0;
  final CarouselController _partOfSpeechCarouselController = CarouselController();
  List<WordStatus> wordStatusList = [];
  List<Activity> activityList = [];

  @override
  void initState() {
    super.initState();
    initTangoList();
    getAllWordStatus();
    getAllActivity();
  }

  void initTangoList() async {
    final lectures = await ref.read(fileControllerProvider.notifier).getPossibleLectures();
    ref.read(tangoListControllerProvider.notifier).getAllTangoList(
        sheetRepo: SheetRepo(lectures.first.spreadsheets.firstWhere((element) => element.name == Config.dictionarySpreadSheetName).id));
  }

  @override
  Widget build(BuildContext context) {
    final tangoMaster = ref.watch(tangoListControllerProvider);
    return Stack(
      children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                SizeConfig.mediumMargin,
                SizeConfig.mediumMargin,
                SizeConfig.mediumMargin,
                SizeConfig.bottomBarHeight),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _userSection(),
                _sectionTitle('レベル別'),
                _carouselLevelLectures(),
                _sectionTitle('カテゴリー別'),
                _carouselCategoryLectures(),
                _sectionTitle('品詞別'),
                _carouselPartOfSpeechLectures(),
              ],
            ),
          ),
        ),
        Visibility(
          visible: tangoMaster.dictionary.allTangos.isEmpty,
          child: Container(
            color: Colors.black.withOpacity(0.2),
            child: Center(
              child: Lottie.asset(
                Assets.lottie.splashScreen,
                height: 300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _userSection() {
    final tangoMaster = ref.watch(tangoListControllerProvider);
    return Card(
        child: Container(
            height: 80,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _userSectionItem(
                  title: '総単語数',
                  data: tangoMaster.dictionary.allTangos.length,
                  unitTitle: '単語'
                ),
                _separater(),
                _userSectionItem(
                  title: '覚えた単語数',
                  data: wordStatusList.where((element) => element.status == WordStatusType.remembered.id).length,
                  unitTitle: '単語'
                ),
                _separater(),
                _userSectionItem(
                  title: '累計学習日数',
                  data: activityList.map((e) => e.date).toList().toSet().toList().length,
                  unitTitle: '日'
                ),
              ],
            )
        )
    );
  }

  Widget _userSectionItem({required String title, required int data, required String unitTitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(SizeConfig.smallMargin),
          child: TextWidget.titleRedMedium(title),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(SizeConfig.smallMargin, 0, SizeConfig.smallMargin, SizeConfig.smallMargin,),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextWidget.titleBlackLargeBold(data.toString()),
                TextWidget.titleGraySmallBold(unitTitle),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _separater() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.mediumMargin),
      child: Container(
        height: double.infinity,
        width: 1,
        color: ColorConfig.bgGreySeparater,
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, SizeConfig.mediumMargin, SizeConfig.mediumMargin, SizeConfig.mediumMargin),
      child: TextWidget.titleBlackLargeBold(title),
    );
  }

  Widget _carouselLevelLectures() {
    return _carouselLectures(
      items: _levelWidgets(),
      controller: _levelCarouselController,
      index: _currentLevelIndex,
    );
  }

  Widget _carouselCategoryLectures() {
    return _carouselLectures(
      items: _categoryWidgets(),
      controller: _categoryCarouselController,
      index: _currentCategoryIndex,
      autoPlay: true,
    );
  }

  Widget _carouselPartOfSpeechLectures() {
    return _carouselLectures(
      items: _partOfSpeechWidgets(),
      controller: _partOfSpeechCarouselController,
      index: _currentPartOfSpeechIndex,
    );
  }

  Widget _carouselLectures({
    required List<Widget> items,
    required CarouselController controller,
    required int index,
    bool autoPlay = false,
    bool visibleIndicator = false,
    bool enlargeCenterPage = false}) {
    return Column(
      children: [
        CarouselSlider(
          items: items,
          carouselController: controller,
          options: CarouselOptions(
              autoPlay: autoPlay,
              enlargeCenterPage: enlargeCenterPage,
              viewportFraction: 0.3,
              aspectRatio: 2.0,
              onPageChanged: (_index, reason) {
                setState(() => index = _index);
              }
          ),
        ),
        Visibility(
          visible: visibleIndicator,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _categoryWidgets().asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () => controller.animateToPage(entry.key),
                child: Container(
                  width: 8.0,
                  height: 8.0,
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (ColorConfig.primaryRed900)
                          .withOpacity(index == entry.key ? 0.9 : 0.2)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<Widget> _levelWidgets() {
    List<Widget> _levels = [];
    LevelGroup.values.forEach((element) {
      _levels.add(_lectureCard(levelGroup: element));
    });
    return _levels;
  }

  List<Widget> _categoryWidgets() {
    List<Widget> _categories = [];
    TangoCategory.values.forEach((element) {
      _categories.add(_lectureCard(category: element));
    });
    return _categories;
  }

  List<Widget> _partOfSpeechWidgets() {
    List<Widget> _partOfSpeechs = [];
    PartOfSpeechEnum.values.forEach((element) {
      _partOfSpeechs.add(_lectureCard(partOfSpeech: element));
    });
    return _partOfSpeechs;
  }

  Widget _lectureCard({TangoCategory? category, PartOfSpeechEnum? partOfSpeech, LevelGroup? levelGroup}) {
    String _title = '';
    SvgGenImage _svg = Assets.svg.islam1;
    if (category != null) {
      _title = category.title;
      _svg = category.svg;
    } else if (partOfSpeech != null) {
      _title = partOfSpeech.title;
      _svg = partOfSpeech.svg;
    } else if (levelGroup != null) {
      _title = levelGroup.title;
      _svg = levelGroup.svg;
    }

    final lectures = ref.watch(fileControllerProvider);
    final _isLoadingLecture = lectures.isEmpty;
    if (_isLoadingLecture) {
      return Card(
        child: Container(
          width: itemCardWidth,
          height: itemCardHeight,
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Container(
                    width: double.infinity,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: FractionalOffset.bottomCenter,
                        end: FractionalOffset.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(SizeConfig.smallMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerWidget.rectangular(
                        height: 20,
                        width: double.infinity,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: InkWell(
        onTap: () {
          ref.read(tangoListControllerProvider.notifier)
              .setLessonsData(
                sheetRepo: SheetRepo(lectures.first.spreadsheets.firstWhere((element) => element.name == Config.dictionarySpreadSheetName).id),
                category: category,
                partOfSpeech: partOfSpeech,
                levelGroup: levelGroup,
              );
          FlashCardScreen.navigateTo(context);
        },
        child: Container(
          width: itemCardWidth,
          height: itemCardHeight,
          child: Stack(
            children: <Widget>[
              _svg.svg(
                alignment: Alignment.center,
                width: double.infinity,
                height: double.infinity,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  child: Container(
                    width: double.infinity,
                    height: itemCardHeight * 0.6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: FractionalOffset.bottomCenter,
                        end: FractionalOffset.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.black.withOpacity(0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(SizeConfig.smallMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.titleWhiteLargeBold(_title, maxLines: 2)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getAllWordStatus() async {
    final database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();

    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findAllWordStatus();
    setState(() => wordStatusList = wordStatus);
  }

  Future<void> getAllActivity() async {
    final database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();

    final activityDao = database.activityDao;
    final _activityList = await activityDao.findAllActivity();
    setState(() => activityList = _activityList);
  }
}
