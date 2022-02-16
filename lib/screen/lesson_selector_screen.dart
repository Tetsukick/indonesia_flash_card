import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/language/v1.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/domain/flashcard_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/category.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/model/level.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';

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

  @override
  void initState() {
    super.initState();
    ref.read(fileControllerProvider.notifier).getPossibleLectures();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(SizeConfig.mediumMargin),
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
      ),
    );
  }

  Widget _userSection() {
    return Card(
        child: Container(
            height: 80,
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _userSectionItem(),
                _separater(),
                _userSectionItem(),
                _separater(),
                _userSectionItem(),
              ],
            )
        )
    );
  }

  Widget _userSectionItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(SizeConfig.smallMargin),
          child: TextWidget.titleRedMedium('継続日数'),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(SizeConfig.smallMargin, 0, SizeConfig.smallMargin, SizeConfig.smallMargin,),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextWidget.titleBlackLargeBold('111'),
                TextWidget.titleGraySmallBold('日'),
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
          ref.read(flashCardControllerProvider.notifier)
              .getQuestionsAndAnswers(
                sheetRepo: SheetRepo(lectures.first.spreadsheets.first.id),
                category: category,
                partOfSpeech: partOfSpeech,
              );
          FlashCardScreen.navigateTo(
            context,
            lectures.first.spreadsheets.first.id,
          );
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
}
