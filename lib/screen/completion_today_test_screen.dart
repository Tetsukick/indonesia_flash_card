// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:indonesia_flash_card/utils/admob.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:social_share/social_share.dart';

// Project imports:
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/model/level.dart';
import 'package:indonesia_flash_card/model/rank.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/shared_preference.dart';
import 'package:indonesia_flash_card/utils/utils.dart';
import '../config/config.dart';
import '../config/size_config.dart';
import '../gen/assets.gen.dart';
import '../model/floor_database/database.dart';
import '../model/floor_entity/word_status.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/floor_migrations/migration_v2_to_v3_add_tango_table.dart';
import '../model/tango_entity.dart';
import '../model/tango_master.dart';
import '../model/word_status_type.dart';
import '../utils/analytics/analytics_event_entity.dart';
import '../utils/analytics/analytics_parameters.dart';
import '../utils/analytics/firebase_analytics.dart';
import '../utils/logger.dart';
import '../utils/shimmer.dart';
import 'dictionary_detail_screen.dart';

class CompletionTodayTestScreen extends ConsumerStatefulWidget {
  const CompletionTodayTestScreen({Key? key}) : super(key: key);

  static void navigateTo(BuildContext context) {
    Navigator.pushReplacement<void, void>(context, MaterialPageRoute(
      builder: (context) {
        return const CompletionTodayTestScreen();
      },
    ),);
  }

  @override
  _CompletionTodayTestScreenState createState() => _CompletionTodayTestScreenState();
}

class _CompletionTodayTestScreenState extends ConsumerState<CompletionTodayTestScreen> {
  final itemCardHeight = 88.0;
  final baseQuestionTime = 1000 * 20;
  final _baseScore = 10.0;
  AppDatabase? database;
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    FirebaseAnalyticsUtils.analytics.logScreenView(screenName: AnalyticsScreen.lessonComp.name);
    initializeDB();
    super.initState();
    PreferenceKey.lastTestDate.setString(Utils.dateTimeToString(DateTime.now()));
  }

  Future<void> initializeDB() async {
    final _database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2, migration2to3])
        .build();
    setState(() => database = _database);
  }

  @override
  Widget build(BuildContext context) {
    final tangoList = ref.watch(tangoListControllerProvider);
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
          height: double.infinity,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _scoreArea(),
              _shareSNSButton(),
              const SizedBox(height: SizeConfig.smallMargin),
              Flexible(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin),
                  itemBuilder: (BuildContext context, int index){
                    final tango = tangoList.lesson.tangos[index];
                    return tangoListItem(tango);
                  },
                  itemCount: tangoList.lesson.tangos.length,
                ),
              ),
              const SizedBox(height: SizeConfig.smallMargin),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _button(
                      onPressed: () async {
                        await Admob().showInterstitialAd();
                        analytics(LessonCompItem.backTop);
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      img: Assets.png.home128,
                      title: 'トップに戻る',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scoreArea() {
    final tangoList = ref.watch(tangoListControllerProvider);
    return Screenshot(
        controller: screenshotController,
        child: Container(
          color: ColorConfig.bgPinkColor,
          child: Column(
            children: [
              const SizedBox(height: SizeConfig.smallestMargin),
              TextWidget.titleGraySmallBold('今日もおつかれさまでした!'),
              const SizedBox(height: SizeConfig.smallestMargin),
              TextWidget.titleGraySmallBold('${Utils.dateTimeToString(DateTime.now())} の結果'),
              const SizedBox(height: SizeConfig.smallMargin),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextWidget.titleGrayLargeBold('総合スコア: '),
                    TextWidget.titleRedLargestBold(calculateTotalScore(tangoList.lesson.quizResults).toStringAsFixed(3)),
                    TextWidget.titleGrayLargeBold(' 点'),
                  ],
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RankExt.doubleToRank(score: calculateTotalScore(tangoList.lesson.quizResults)).img.image(width: 30, height: 30),
                    const SizedBox(width: SizeConfig.mediumSmallMargin),
                    TextWidget.titleRedLargestBold(RankExt.doubleToRank(score: calculateTotalScore(tangoList.lesson.quizResults)).title),
                  ],
              ),
              const SizedBox(height: SizeConfig.smallMargin),
            ],
          ),
        ),
    );
  }

  Widget tangoListItem(TangoEntity tango) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
      child: InkWell(
        onTap: () {
          analytics(LessonCompItem.tangoCard);
          DictionaryDetail.navigateTo(context, tangoEntity: tango);
        },
        child: Card(
          child: SizedBox(
            width: double.infinity,
            height: itemCardHeight,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin, horizontal: SizeConfig.mediumSmallMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      wordStatus(tango),
                      const SizedBox(height: SizeConfig.smallestMargin,),
                      TextWidget.titleBlackMediumBold(tango.indonesian ?? ''),
                      const SizedBox(height: 2,),
                      TextWidget.titleGraySmall(tango.japanese ?? ''),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: bookmark(tango),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<WordStatus?> getWordStatus(TangoEntity entity) async {
    final wordStatusDao = database?.wordStatusDao;
    final wordStatus = await wordStatusDao?.findWordStatusById(entity.id!);
    return wordStatus;
  }

  Future<WordStatus?> getBookmark(TangoEntity entity) async {
    final wordStatusDao = database?.wordStatusDao;
    final wordStatus = await wordStatusDao?.findWordStatusById(entity.id!);
    return wordStatus;
  }

  Widget _button({required VoidCallback? onPressed, required AssetGenImage img, required String title}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: ColorConfig.primaryRed900,
        backgroundColor: Colors.white,
        shape: const StadiumBorder(),
      ),
      child: SizedBox(
        height: 50,
        width: 112,
        child: Row(
          children: [
            img.image(height: 20, width: 20),
            const SizedBox(width: SizeConfig.smallMargin),
            TextWidget.titleRedMedium(title),
          ],
        ),
      ),
    );
  }

  Widget bookmark(TangoEntity entity) {
    return FutureBuilder(
        future: getBookmark(entity),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final status = snapshot.data as WordStatus?;
            final isBookmark = status == null ? false : status.isBookmarked;
            return Visibility(
              visible: isBookmark,
              child: Padding(
                padding: const EdgeInsets.only(right: SizeConfig.mediumSmallMargin),
                child: Assets.png.bookmarkOn64.image(height: 24, width: 24),
              ),
            );
          } else {
            return  const Padding(
              padding: EdgeInsets.only(right: SizeConfig.mediumSmallMargin),
              child: ShimmerWidget.rectangular(width: 24, height: 24,),
            );
          }
        },);
  }

  Widget wordStatus(TangoEntity entity) {
    return FutureBuilder(
        future: getWordStatus(entity),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final status = snapshot.data as WordStatus?;
            final statusType = status == null ? WordStatusType.notLearned : WordStatusTypeExt.intToWordStatusType(status.status);
            return Row(
              children: [
                statusType.icon,
                const SizedBox(width: SizeConfig.smallestMargin),
                TextWidget.titleGraySmallest(statusType.title),
              ],
            );
          } else {
            return const Row(
              children: [
                ShimmerWidget.circular(width: 16, height: 16),
                SizedBox(width: SizeConfig.smallestMargin),
                ShimmerWidget.rectangular(height: 12, width: 80),
              ],
            );
          }
        },);
  }

  void analytics(LessonCompItem item, {String? others = ''}) {
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

  double calculateTotalScore(List<QuizResult> results) {
    double score = 0;
    results.forEach((result) {
      if (result.isCorrect) {
        final _factor = LevelGroupExt.intToLevelGroup(value: result.entity!.level!).testFactor;
        final _baseLevelScore = _baseScore * _factor * (result.isUsedHint ? 0.9 : 1);
        score += _baseLevelScore;
        score += _baseLevelScore * ((baseQuestionTime - result.answerTime) / baseQuestionTime);
      }
    });
    return score;
  }

  Widget _shareSNSButton() {
    return Card(
        child: InkWell(
          onTap: () async {
            await shareSNS();
          },
          child: SizedBox(
              height: 40,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                        child: Assets.png.snsShare128.image(height: 20, width: 20),
                      ),
                      TextWidget.titleGraySmallBold('SNSでシェア'),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeConfig.mediumSmallMargin),
                    child: Icon(Icons.arrow_forward_ios_sharp, size: 20),
                  ),
                ],
              ),
          ),
        ),
    );
  }

  Future<void> shareSNS() async {
    final tangoList = ref.watch(tangoListControllerProvider);
    await screenshotController.capture().then((image) async {
      final directory = await getApplicationDocumentsDirectory();
      final file = await File('${directory.path}/temp.png').create();
      await file.writeAsBytes(image!);
      await SocialShare.shareOptions(
          '本日のインドネシア単語検定\nスコア: ${calculateTotalScore(tangoList.lesson.quizResults).toStringAsFixed(3)} 点\nランク: ${RankExt.doubleToRank(score: calculateTotalScore(tangoList.lesson.quizResults)).title}\n#BINTANGO #インドネシア語学習'
          ,imagePath: file.path,);
    });
  }
}
