import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/screen/quiz_screen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';
import 'package:indonesia_flash_card/utils/utils.dart';
import 'package:lottie/lottie.dart';

import '../config/config.dart';
import '../model/floor_database/database.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/part_of_speech.dart';
import '../utils/analytics/analytics_event_entity.dart';
import '../utils/analytics/analytics_parameters.dart';
import '../utils/analytics/firebase_analytics.dart';
import '../utils/shared_preference.dart';

class FlashCardScreen extends ConsumerStatefulWidget {

  static void navigateTo(BuildContext context) {
    Navigator.push<void>(context, MaterialPageRoute(
      builder: (context) {
        return FlashCardScreen();
      },
    ));
  }

  static void navigateReplacementTo(BuildContext context) {
    Navigator.pushReplacement<void, void>(context, MaterialPageRoute(
      builder: (context) {
        return FlashCardScreen();
      },
    ));
  }

  const FlashCardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FlashCardScreen> createState() => _FlushScreenState();
}

class _FlushScreenState extends ConsumerState<FlashCardScreen> {
  int currentIndex = 0;
  bool cardFlipped = false;
  bool allCardsFinished = false;
  final _cardHeight = 100.0;
  FlutterTts flutterTts = FlutterTts();
  bool _isSoundOn = false;
  final _iconHeight = 20.0;
  final _iconWidth = 20.0;
  AppDatabase? database;
  
  @override
  void initState() {
    FirebaseAnalyticsUtils.analytics.setCurrentScreen(screenName: AnalyticsScreen.flushCard.name);
    initializeDB();
    setTTS();
    loadSoundSetting();
    super.initState();
  }
  
  void setTTS() {
    flutterTts.setLanguage('id-ID');
  }

  void loadSoundSetting() async {
    _isSoundOn = await PreferenceKey.isSoundOn.getBool();
    setState(() {});
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.isEmpty) {
      return;
    }
    if (_isSoundOn) {
      flutterTts.speak(questionAnswerList.lesson.tangos[currentIndex].indonesian ?? '');
    }
  }

  void initializeDB() async {
    final _database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();;
    setState(() => database = _database);
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _topBarSection(),
                SizedBox(height: SizeConfig.smallMargin),
                _flashCardFront(),
                SizedBox(height: SizeConfig.smallMargin),
                _flashCardBack(),
                _actionButtonSection()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBarSection() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.titleGraySmallBold('${currentIndex + 1} / ${questionAnswerList.lesson.tangos.length} 問目'),
        SizedBox(width: SizeConfig.smallMargin),
        Utils.soundSettingSwitch(value: _isSoundOn,
            onToggle: (val) {
              setState(() => _isSoundOn = val);
              PreferenceKey.isSoundOn.setBool(val);
            }
        ),
        Spacer(),
        IconButton(
            onPressed: () {
              analytics(FlushCardItem.back);
              Navigator.pop(context);
            },
            icon: Icon(Icons.close,
              color: ColorConfig.bgGrey,
              size: SizeConfig.largeSmallMargin,
            ))
      ],
    );
  }

  Widget _flashCardFront() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.isEmpty) {
      return _shimmerFlashCard(isTappable: false, isJapanese: false);
    }
    if (_isSoundOn) {
      flutterTts.speak(questionAnswerList.lesson.tangos[currentIndex].indonesian ?? '');
    }
    return _flashCard(
        title: 'インドネシア語',
        tango: questionAnswerList.lesson.tangos[currentIndex]);
  }

  Widget _flashCardBack() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.isEmpty) {
      return _shimmerFlashCard(isTappable: false);
    } else if (!cardFlipped) {
      return _shimmerFlashCard(isTappable: true);
    }
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    return Card(
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _partOfSpeech(entity),
              SizedBox(height: SizeConfig.smallMargin),
              _japanese(entity),
              SizedBox(height: SizeConfig.smallMargin),
              _english(entity),
              SizedBox(height: SizeConfig.smallMargin),
              _exampleHeader(),
              SizedBox(height: SizeConfig.smallMargin),
              _example(entity),
              SizedBox(height: SizeConfig.smallMargin),
              _exampleJp(entity),
              SizedBox(height: SizeConfig.smallMargin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _flashCard({required String title, required TangoEntity tango, bool isFront = true}) {
    return Card(
      child: Container(
        height: _cardHeight,
        width: double.infinity,
        child: Stack(
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextWidget.titleRedMedium(title),
                  Flexible(child: TextWidget.titleBlackLargestBold(tango.indonesian!, maxLines: 2)),
                ],
              ),
            ),
            Visibility(
              visible: isFront,
              child: Align(
                alignment: Alignment.topRight,
                child: _soundButton(tango.indonesian!),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: SizeConfig.mediumSmallMargin),
                child: bookmark(tango),
              ),
            ),
          ],
        )
      ),
    );
  }

  Widget bookmark(TangoEntity entity) {
    final wordStatusDao = database?.wordStatusDao;

    return FutureBuilder(
        future: getBookmark(entity),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            WordStatus? status = snapshot.data as WordStatus?;
            bool isBookmark = status == null ? false : status.isBookmarked;
            if (status == null) {
              status = WordStatus(wordId: entity.id!, status: WordStatusType.notLearned.id, isBookmarked: false);
              wordStatusDao?.insertWordStatus(status);
            }
            return Padding(
              padding: const EdgeInsets.only(left: SizeConfig.mediumSmallMargin),
              child: InkWell(
                  onTap: () {
                    analytics(FlushCardItem.bookmark);
                    wordStatusDao?.updateWordStatus(status!..isBookmarked = !isBookmark);
                    setState(() => isBookmark = !isBookmark);
                  },
                  child: isBookmark ? Assets.png.bookmarkOn64.image(height: 32, width: 32)
                      : Assets.png.bookmarkOff64.image(height: 32, width: 32),
              ),
            );
          } else {
            return  Padding(
              padding: const EdgeInsets.only(left: SizeConfig.mediumSmallMargin),
              child: ShimmerWidget.rectangular(width: 24, height: 24,),
            );
          }
        });
  }

  Future<WordStatus?> getBookmark(TangoEntity entity) async {
    final wordStatusDao = database?.wordStatusDao;
    final wordStatus = await wordStatusDao?.findWordStatusById(entity.id!);
    return wordStatus;
  }

  Widget _partOfSpeech(TangoEntity entity) {
    return Row(
      children: [
        TextWidget.titleWhiteSmallBoldWithBackGround(PartOfSpeechExt.intToPartOfSpeech(value: entity.partOfSpeech!).title),
        SizedBox(width: SizeConfig.mediumSmallMargin),
      ],
    );
  }

  Widget _japanese(TangoEntity entity) {
    return Row(
      children: [
        Assets.png.japanFuji64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleGrayLargeBold(entity.japanese!, maxLines: 2)),
      ],
    );
  }

  Widget _english(TangoEntity entity) {
    return Row(
      children: [
        Assets.png.english64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleGrayLargeBold(entity.english!, maxLines: 2)),
      ],
    );
  }

  Widget _exampleHeader() {
    return Row(
      children: [
        TextWidget.titleRedMedium('例文', maxLines: 1),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: _separater())
      ],
    );
  }

  Widget _example(TangoEntity entity) {
    return Row(
      children: [
        Assets.png.example64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleBlackMediumBold(entity.example!, maxLines: 5)),
      ],
    );
  }

  Widget _exampleJp(TangoEntity entity) {
    return Row(
      children: [
        Assets.png.japan64.image(height: _iconHeight, width: _iconWidth),
        SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(child: TextWidget.titleGrayMediumSmallBold(entity.exampleJp!, maxLines: 5)),
      ],
    );
  }

  Widget _separater() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.mediumMargin),
      child: Container(
        height: 1,
        width: double.infinity,
        color: ColorConfig.bgGreySeparater,
      ),
    );
  }

  Widget _soundButton(String data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            analytics(FlushCardItem.sound);
            flutterTts.speak(data);
          },
          child: Padding(
            padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
            child: Lottie.asset(
              Assets.lottie.speaker,
              height: _cardHeight / 3,
            ),
          ),
        ),
      ],
    );
  }

  Widget _shimmerFlashCard({required bool isTappable, bool isJapanese = true}) {
    return Stack(
      children: [
        Card(
          child: Container(
            height: _cardHeight,
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextWidget.titleRedMedium(isJapanese ? '日本語' : 'インドネシア語'),
                  ShimmerWidget.rectangular(height: 40, width: 240,)
                ],
              ),
            ),
          ),
        ),
        Visibility(
          visible: isTappable,
          child: Align(
            alignment: Alignment.center,
            child: TextButton(
              child: Container(
                height: _cardHeight,
                width: double.infinity,
                child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          Assets.lottie.tap,
                          height: _cardHeight / 3,
                        ),
                        SizedBox(height: SizeConfig.smallMargin,),
                        TextWidget.titleGraySmallBold('タップして日本語の意味を表示')
                      ],
                    )
                ),
              ),
              style: TextButton.styleFrom(
                primary: ColorConfig.bgGreySeparater,
              ),
              onPressed: () => setState(() {
                analytics(FlushCardItem.openCard);
                cardFlipped = true;
              }),
            ),
          ),
        )
      ],
    );
  }

  Widget _actionButtonSection() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    return Visibility(
      visible: questionAnswerList.lesson.tangos.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.all(SizeConfig.smallMargin),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _actionButton(type: WordStatusType.notRemembered),
            _actionButton(type: WordStatusType.remembered),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({required WordStatusType type}) {
    return Card(
      shape: CircleBorder(),
      child: InkWell(
        child: Container(
            height: 120,
            width: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                type.iconLarge,
                SizedBox(height: SizeConfig.smallMargin),
                TextWidget.titleGraySmallBold(type.actionTitle)
              ],
            )
        ),
        onTap: () async {
          analytics(type.analyticsItem);
          if (type == WordStatusType.notRemembered) {
            await registerWordStatus(type: type);
          }
          getNextCard();
        },
      ),
    );
  }

  Future<void> registerWordStatus({required WordStatusType type}) async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final currentTango = questionAnswerList.lesson.tangos[currentIndex];
    final database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();

    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findWordStatusById(currentTango.id!);
    if (wordStatus != null) {
      await wordStatusDao.updateWordStatus(wordStatus..status = type.id);
    } else {
      await wordStatusDao.insertWordStatus(WordStatus(wordId: currentTango.id!, status: type.id));
    }
  }

  void getNextCard() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.length <= currentIndex + 1) {
      setState(() => allCardsFinished = true);
      QuizScreen.navigateReplacementTo(context);
      return;
    }
    setState(() {
      cardFlipped = false;
      currentIndex++;
    });
  }

  void analytics(FlushCardItem item, {String? others = ''}) {
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
}
