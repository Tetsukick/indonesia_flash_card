import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';

import '../../../config/size_config.dart';
import '../../../domain/file_service.dart';
import '../../../domain/tango_list_service.dart';
import '../../../model/category.dart';
import '../../../model/frequency.dart';
import '../../../model/level.dart';
import '../../../utils/admob.dart';
import '../../../utils/analytics/analytics_event_entity.dart';
import '../../../utils/analytics/analytics_parameters.dart';
import '../../../utils/analytics/firebase_analytics.dart';
import '../../../utils/common_text_widget.dart';
import '../../../utils/shimmer.dart';
import '../../flush_card_screen.dart';

class LessonCard extends ConsumerWidget {

  const LessonCard({Key? key, this.category, this.partOfSpeech, this.levelGroup, this.frequencyGroup}) : super(key: key);
  final itemCardWidth = 200.0;
  final itemCardHeight = 160.0;

  final TangoCategory? category;
  final PartOfSpeechEnum? partOfSpeech;
  final LevelGroup? levelGroup;
  final FrequencyGroup? frequencyGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final tangoMaster = ref.watch(tangoListControllerProvider);
    // if ((tangoMaster.dictionary.allTangos.isNotEmpty) && !isLoadAchievementRate) {
    //   // getAchievementRate();
    // }

    return _lectureCard(
      context,
      ref,
      category: category,
      partOfSpeech: partOfSpeech,
      levelGroup: levelGroup,
      frequencyGroup: frequencyGroup,
    );
  }

  Widget _lectureCard(BuildContext context, WidgetRef ref, {TangoCategory? category, PartOfSpeechEnum? partOfSpeech, LevelGroup? levelGroup, FrequencyGroup? frequencyGroup}) {
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
    } else if (frequencyGroup != null) {
      _title = frequencyGroup.title;
      _svg = frequencyGroup.svg;
    }

    final lectures = ref.watch(fileControllerProvider);
    final _isLoadingLecture = lectures.isEmpty;
    if (_isLoadingLecture) {
      return shimmerLessonCard();
    }

    return Card(
      child: InkWell(
        onTap: () async {
          var rand = new math.Random();
          int lottery = rand.nextInt(3);
          if (lottery == 0) {
            await Admob().showInterstitialAd();
          }

          analytics(LectureSelectorItem.lessonCard,
              others: 'category: ${category?.id}, partOfSpeech: ${partOfSpeech?.id}, levelGroup: ${levelGroup?.index}, frequencyGroup: ${frequencyGroup?.index}');

          await ref.read(tangoListControllerProvider.notifier)
              .setLessonsData(
            category: category,
            partOfSpeech: partOfSpeech,
            levelGroup: levelGroup,
            frequencyGroup: frequencyGroup,
          );
          if (!context.mounted) return;
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
              SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(SizeConfig.smallMargin),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.titleWhiteLargeBold(_title, maxLines: 2),
                      // SizedBox(height: SizeConfig.mediumMargin,)
                    ],
                  ),
                ),
              ),
              // Align(
              //   alignment: Alignment.bottomCenter,
              //   child: Padding(
              //     padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallestMargin),
              //     child: LinearPercentIndicator(
              //       width: 88,
              //       lineHeight: 14.0,
              //       percent: achievementRate,
              //       center: Text('${(achievementRate * 100).toStringAsFixed(2)} %'),
              //       backgroundColor: Colors.grey,
              //       progressColor: ColorConfig.green,
              //       linearStrokeCap: LinearStrokeCap.roundAll,
              //     ),
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Widget shimmerLessonCard() {
    return Card(
      child: SizedBox(
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
            SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.all(SizeConfig.smallMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ShimmerWidget.rectangular(
                      height: 20,
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

  void analytics(LectureSelectorItem item, {String? others = ''}) {
    final eventDetail = AnalyticsEventAnalyticsEventDetail()
      ..id = item.id.toString()
      ..screen = AnalyticsScreen.lectureSelector.name
      ..item = item.shortName
      ..action = AnalyticsActionType.tap.name
      ..others = others;
    FirebaseAnalyticsUtils.eventsTrack(AnalyticsEventEntity()
      ..name = item.name
      ..analyticsEventDetail = eventDetail);
  }

  // void getAchievementRate() async {
  //   if (this.category == null && this.frequencyGroup == null && this.levelGroup == null && this.partOfSpeech == null) {
  //     return;
  //   }
  //   setState(() => isLoadAchievementRate = true);
  //   final _achievementRate = await ref.read(tangoListControllerProvider.notifier)
  //       .achievementRate(
  //         category: this.category,
  //         partOfSpeech: this.partOfSpeech,
  //         levelGroup: this.levelGroup,
  //         frequencyGroup: this.frequencyGroup,
  //       );
  //
  //   setState(() => achievementRate = _achievementRate);
  // }
}
