import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/config.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../config/size_config.dart';
import '../../../domain/file_service.dart';
import '../../../domain/tango_list_service.dart';
import '../../../model/category.dart';
import '../../../model/frequency.dart';
import '../../../model/level.dart';
import '../../../utils/analytics/analytics_event_entity.dart';
import '../../../utils/analytics/analytics_parameters.dart';
import '../../../utils/analytics/firebase_analytics.dart';
import '../../../utils/common_text_widget.dart';
import '../../../utils/logger.dart';
import '../../../utils/shimmer.dart';
import '../../flush_card_screen.dart';

class LessonCard extends ConsumerStatefulWidget {
  final TangoCategory? category;
  final PartOfSpeechEnum? partOfSpeech;
  final LevelGroup? levelGroup;
  final FrequencyGroup? frequencyGroup;

  const LessonCard({Key? key, this.category, this.partOfSpeech, this.levelGroup, this.frequencyGroup}) : super(key: key);

  @override
  _LessonCardState createState() => _LessonCardState();
}

class _LessonCardState extends ConsumerState<LessonCard> {
  final itemCardWidth = 200.0;
  final itemCardHeight = 160.0;
  double achievementRate = 0.0;
  bool isLoadAchievementRate = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    loadInterstitialAd();
  }

  @override
  Widget build(BuildContext context) {
    final tangoMaster = ref.watch(tangoListControllerProvider);
    if ((tangoMaster.dictionary.allTangos.isNotEmpty) && !isLoadAchievementRate) {
      getAchievementRate();
    }

    return _lectureCard(
      category: this.widget.category,
      partOfSpeech: this.widget.partOfSpeech,
      levelGroup: this.widget.levelGroup,
      frequencyGroup: this.widget.frequencyGroup
    );
  }

  Widget _lectureCard({TangoCategory? category, PartOfSpeechEnum? partOfSpeech, LevelGroup? levelGroup, FrequencyGroup? frequencyGroup}) {
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
          int lottery = rand.nextInt(5);
          if (lottery == 4) {
            await showInterstitialAd();
          }

          analytics(LectureSelectorItem.lessonCard,
              others: 'category: ${category?.id}, partOfSpeech: ${partOfSpeech?.id}, levelGroup: ${levelGroup?.index}, frequencyGroup: ${frequencyGroup?.index}');

          ref.read(tangoListControllerProvider.notifier)
              .setLessonsData(
            category: category,
            partOfSpeech: partOfSpeech,
            levelGroup: levelGroup,
            frequencyGroup: frequencyGroup,
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
                      SizedBox(height: SizeConfig.mediumMargin,)
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallestMargin),
                  child: LinearPercentIndicator(
                    width: 88,
                    lineHeight: 14.0,
                    percent: achievementRate,
                    center: Text('${(achievementRate * 100).toStringAsFixed(2)} %'),
                    backgroundColor: Colors.grey,
                    progressColor: ColorConfig.green,
                    linearStrokeCap: LinearStrokeCap.roundAll,
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

  void getAchievementRate() async {
    if (this.widget.category == null && this.widget.frequencyGroup == null && this.widget.levelGroup == null && this.widget.partOfSpeech == null) {
      return;
    }
    setState(() => isLoadAchievementRate = true);
    final _achievementRate = await ref.read(tangoListControllerProvider.notifier)
        .achievementRate(
          category: this.widget.category,
          partOfSpeech: this.widget.partOfSpeech,
          levelGroup: this.widget.levelGroup,
          frequencyGroup: this.widget.frequencyGroup,
        );

    setState(() => achievementRate = _achievementRate);
  }

  Future<void> loadInterstitialAd() async {
    await InterstitialAd.load(
        adUnitId: Platform.isIOS ?
          Config.adUnitIdIosInterstitial : Config.adUnitIdAndroidInterstitial,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            logger.d('Ad loaded.${ad}');
          },
          onAdFailedToLoad: (LoadAdError error) {
            logger.d('Ad failed to load: $error');
          },
        ));
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd != null) {
      await _interstitialAd?.show();
    }
  }
}
