import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/file_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/lecture.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              _lectureCard()
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

  Widget _lectureCard() {
    final lectures = ref.watch(fileControllerProvider);
    final _isLoadingLecture = lectures.isEmpty;
    if (_isLoadingLecture) {
      return Row(
        children: [
          Card(
            child: Container(
              width: 200,
              height: 160,
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
          )
        ],
      );

    }

    return Row(
      children: [
        Card(
          child: InkWell(
            onTap: () {
              FlushScreen.navigateTo(
                context,
                lectures.first.spreadsheets.first.id,
              );
            },
            child: Container(
              width: 200,
              height: 160,
              child: Stack(
                children: <Widget>[
                  Assets.svg.eat.svg(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: double.infinity,
                  ),
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
                          TextWidget.titleWhiteLargeBold(lectures.first.spreadsheets.first.name)
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
      ],
    );
  }
}
