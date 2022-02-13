import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/domain/flashcard_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/category.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';

import 'home/flush_card_screen.dart';

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
  int _currentCategoryIndex = 0;
  final CarouselController _categoryCarouselController = CarouselController();

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
        child: Padding(
          padding: const EdgeInsets.all(SizeConfig.mediumMargin),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _userSection(),
              _sectionTitle(),
              _carouselCategoryLectures()
            ],
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

  Widget _sectionTitle() {
    return Padding(
      padding: EdgeInsets.fromLTRB(0, SizeConfig.mediumMargin, SizeConfig.mediumMargin, SizeConfig.mediumMargin),
      child: TextWidget.titleBlackLargeBold('カテゴリー'),
    );
  }

  Widget _carouselCategoryLectures() {
    return Column(
      children: [
        CarouselSlider(
          items: _categoryWidgets(),
          carouselController: _categoryCarouselController,
          options: CarouselOptions(
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.6,
              aspectRatio: 2.0,
              onPageChanged: (index, reason) {
                setState(() => _currentCategoryIndex = index);
              }
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _categoryWidgets().asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _categoryCarouselController.animateToPage(entry.key),
              child: Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (ColorConfig.primaryRed900)
                        .withOpacity(_currentCategoryIndex == entry.key ? 0.9 : 0.2)),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  List<Widget> _categoryWidgets() {
    List<Widget> _categories = [];
    TangoCategory.values.forEach((element) {
      _categories.add(_lectureCard(element));
    });
    return _categories;
  }

  Widget _lectureCard(TangoCategory category) {
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
                category: category
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
              category.svg.svg(
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
                      TextWidget.titleWhiteLargeBold(category.title)
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
