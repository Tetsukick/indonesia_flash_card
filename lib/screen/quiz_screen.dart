import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/floor_entity/activity.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/screen/completion_screen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/logger.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';
import 'package:indonesia_flash_card/utils/utils.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../config/config.dart';
import '../model/floor_database/database.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/part_of_speech.dart';
import '../utils/analytics/analytics_event_entity.dart';
import '../utils/analytics/analytics_parameters.dart';
import '../utils/analytics/firebase_analytics.dart';
import '../utils/shared_preference.dart';

class QuizScreen extends ConsumerStatefulWidget {

  static void navigateTo(BuildContext context) {
    Navigator.push<void>(context, MaterialPageRoute(
      builder: (context) {
        return QuizScreen();
      },
    ));
  }

  static void navigateReplacementTo(BuildContext context) {
    Navigator.pushReplacement<void, void>(context, MaterialPageRoute(
      builder: (context) {
        return QuizScreen();
      },
    ));
  }

  const QuizScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentIndex = 0;
  bool allCardsFinished = false;
  final _cardHeight = 100.0;
  final _iconHeight = 20.0;
  final _iconWidth = 20.0;
  late AppDatabase database;
  StreamController<ErrorAnimationType>? errorController;
  String currentText = "";
  PinCodeTextField? pinCodeTextField;
  CountdownTimerController? countDownController;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 15;

  @override
  void initState() {
    FirebaseAnalyticsUtils.analytics.setCurrentScreen(screenName: AnalyticsScreen.quiz.name);
    initializeDB();
    super.initState();
    initializePinCodeTextField();
  }

  void initializeDB() async {
    final _database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();
    setState(() => database = _database);
  }

  void initializePinCodeTextField() async {
    await Future<void>.delayed(Duration(seconds: 1));
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    setPinCodeTextField(entity);
  }

  @override
  void dispose() {
    errorController?.close();
    countDownController?.dispose();
    super.dispose();
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
                _questionTitleCard(),
                SizedBox(height: SizeConfig.smallMargin),
                _questionAnswerCard(),
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
        CountdownTimer(
          controller: countDownController,
          endTime: endTime,
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

  Widget _questionTitleCard() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.isEmpty) {
      return _shimmerFlashCard();
    }
    return _flashCard(
        title: '日本語',
        tango: questionAnswerList.lesson.tangos[currentIndex]);
  }

  Widget _questionAnswerCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextWidget.titleGrayMediumBold('上記の日本語に適するインドネシア語を入力してください'),
            _separater(),
            if (pinCodeTextField != null) pinCodeTextField!,
          ],
        ),
      ),
    );
  }

  void _answer(String input) {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    if (entity.indonesian!.toLowerCase() == input.toLowerCase()) {
      getNextCard();
    } else {
      errorController?.add(ErrorAnimationType.shake);
    }
  }

  Widget _flashCard({required String title, required TangoEntity tango, bool isFront = true}) {
    return Card(
      child: Container(
          height: _cardHeight,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextWidget.titleRedMedium(title),
              Flexible(child: TextWidget.titleBlackLargestBold(tango.japanese!, maxLines: 2)),
            ],
          )
      ),
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

  Widget _shimmerFlashCard({bool isJapanese = true}) {
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
      ],
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

  Future<void> registerActivity() async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final currentTango = questionAnswerList.lesson.tangos[currentIndex];
    final database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2])
        .build();

    final activityDao = database.activityDao;
    final now = Utils.dateTimeToString(DateTime.now());
    await activityDao.insertActivity(Activity(date: now, wordId: currentTango.id!));
  }

  void getNextCard() async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.length <= currentIndex + 1) {
      setState(() => allCardsFinished = true);
      CompletionScreen.navigateTo(context);
      return;
    }
    setState(() {
      currentText = '';
    });
    setState(() {
      currentIndex++;
    });
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    setPinCodeTextField(entity);
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

  void setPinCodeTextField(TangoEntity entity) async {
    setState(() {
      pinCodeTextField = null;
      errorController?.close();
      errorController = null;
      countDownController = null;
    });

    await Future<void>.delayed(Duration(seconds: 1));

    setCountDownController();
    setState(() {
      errorController = StreamController<ErrorAnimationType>();
      pinCodeTextField = PinCodeTextField(
        length: entity.indonesian?.length ?? 0,
        obscureText: false,
        animationType: AnimationType.fade,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: 40,
          fieldWidth: 30,
          activeFillColor: Colors.white,
          activeColor: ColorConfig.green,
          inactiveColor: ColorConfig.green,
          inactiveFillColor: Colors.white,
          selectedColor: ColorConfig.primaryRed900,
          selectedFillColor: Colors.white,
        ),
        animationDuration: Duration(milliseconds: 300),
        enableActiveFill: true,
        errorAnimationController: errorController,
        controller: TextEditingController(),
        onCompleted: (v) {
          logger.d(v);
          _answer(v);
        },
        onChanged: (value) {
          setState(() {
            currentText = value;
          });
        },
        appContext: context,
      );
    });
  }

  void setCountDownController() {
    setState(() {
      endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 15;
      countDownController = CountdownTimerController(
        endTime: endTime,
        onEnd: () {
          getNextCard();
        },
      );
    });
  }
}
