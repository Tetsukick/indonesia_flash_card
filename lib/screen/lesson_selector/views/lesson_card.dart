// Dart imports:
import 'dart:math' as math;

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/model/floor_entity/achievement_rate.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

// Project imports:
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

  const LessonCard({Key? key, this.category, this.partOfSpeech, this.levelGroup, this.frequencyGroup, this.achievementRate}) : super(key: key);
  final itemCardWidth = 200.0;
  final itemCardHeight = 160.0;

  final TangoCategory? category;
  final PartOfSpeechEnum? partOfSpeech;
  final LevelGroup? levelGroup;
  final FrequencyGroup? frequencyGroup;
  final AchievementRate? achievementRate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
    var title = '';
    var svg = Assets.svg.islam1;
    if (category != null) {
      title = category.title;
      svg = category.svg;
    } else if (partOfSpeech != null) {
      title = partOfSpeech.title;
      svg = partOfSpeech.svg;
    } else if (levelGroup != null) {
      title = levelGroup.title;
      svg = levelGroup.svg;
    } else if (frequencyGroup != null) {
      title = frequencyGroup.title;
      svg = frequencyGroup.svg;
    }

    final lectures = ref.watch(fileControllerProvider);
    final isLoadingLecture = lectures.isEmpty;

    return Card(
      child: InkWell(
        onTap: () async {
          final rand = math.Random();
          final lottery = rand.nextInt(3);
          if (lottery == 0) {
            await Admob().showInterstitialAd();
          }

          analytics(LectureSelectorItem.lessonCard,
              others: 'category: ${category?.id}, partOfSpeech: ${partOfSpeech?.id}, levelGroup: ${levelGroup?.index}, frequencyGroup: ${frequencyGroup?.index}',);

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
        child: SizedBox(
          width: itemCardWidth,
          height: itemCardHeight,
          child: Stack(
            children: <Widget>[
              svg.svg(
                width: double.infinity,
                height: double.infinity,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: itemCardHeight * 0.6,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
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
              SizedBox.expand(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: SizeConfig.smallMargin,
                    right: SizeConfig.smallMargin,
                    top: SizeConfig.smallMargin,
                    bottom: SizeConfig.mediumLargestMargin,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextWidget.titleWhiteLargeBold(title, maxLines: 2),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(
                      bottom: SizeConfig.smallMargin),
                  child: LinearPercentIndicator(
                    width: itemCardWidth * 0.55,
                    lineHeight: 14.0,
                    percent: achievementRate?.rate ?? 0,
                    center: TextWidget.titleNumberGraySmall('${((achievementRate?.rate ?? 0) * 100).toStringAsFixed(2)} %'),
                    backgroundColor: Colors.grey,
                    progressColor: ColorConfig.green,
                    barRadius: const Radius.circular(10),
                  ),
                ),
              )
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
            const SizedBox.expand(
              child: Padding(
                padding: EdgeInsets.all(SizeConfig.smallMargin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
      ..id = item.id
      ..screen = AnalyticsScreen.lectureSelector.name
      ..item = item.shortName
      ..action = AnalyticsActionType.tap.name
      ..others = others;
    FirebaseAnalyticsUtils.eventsTrack(AnalyticsEventEntity()
      ..name = item.name
      ..analyticsEventDetail = eventDetail,);
  }
}