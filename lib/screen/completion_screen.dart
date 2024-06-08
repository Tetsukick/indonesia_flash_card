import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/screen/flush_card_screen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';

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
import '../utils/shimmer.dart';
import 'dictionary_detail_screen.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({Key? key}) : super(key: key);

  static void navigateTo(BuildContext context) {
    Navigator.pushReplacement<void, void>(context, MaterialPageRoute(
      builder: (context) {
        return const CompletionScreen();
      },
    ),);
  }

  @override
  _CompletionScreenState createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  final itemCardHeight = 88.0;
  final baseQuestionTime = 1000 * 15;
  final _baseScore = 10.0;
  AppDatabase? database;

  @override
  void initState() {
    FirebaseAnalyticsUtils.analytics.setCurrentScreen(screenName: AnalyticsScreen.lessonComp.name);
    initializeDB();
    super.initState();
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
              const SizedBox(height: SizeConfig.mediumSmallMargin),
              TextWidget.titleGraySmallBold('おつかれさまでした!'),
              const SizedBox(height: SizeConfig.smallMargin),
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
                      onPressed: () {
                        analytics(LessonCompItem.continueBtn);
                        ref.read(tangoListControllerProvider.notifier)
                            .resetLessonsData();
                        FlashCardScreen.navigateReplacementTo(context);
                      },
                      img: Assets.png.continue128,
                      title: '同設定で継続',
                  ),
                  const SizedBox(width: SizeConfig.smallMargin),
                  _button(
                      onPressed: () {
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
            Expanded(child: TextWidget.titleRedMedium(title)),
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

  String calculateTotalScore(List<QuizResult> results) {
    double score = 0;
    results.forEach((result) {
      if (result.isCorrect) {
        score += _baseScore;
        score += _baseScore * ((baseQuestionTime - result.answerTime) / baseQuestionTime);
      }
    });
    return score.toStringAsFixed(3);
  }
}
