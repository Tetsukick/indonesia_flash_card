// Dart imports:
import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;

// Flutter imports:
import 'package:audioplayers/audioplayers.dart';
import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// Project imports:
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/floor_entity/activity.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/part_of_speech.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/tango_master.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/screen/completion_screen.dart';
import 'package:indonesia_flash_card/screen/completion_today_test_screen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/disable_focus_node.dart';
import 'package:indonesia_flash_card/utils/logger.dart';
import 'package:indonesia_flash_card/utils/shared_preference.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';
import 'package:indonesia_flash_card/utils/shuffle_string.dart';
import 'package:indonesia_flash_card/utils/string_ext.dart';
import 'package:indonesia_flash_card/utils/utils.dart';
import 'package:indonesia_flash_card/utils/waitable_button.dart';
import 'package:lottie/lottie.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../config/config.dart';
import '../model/floor_database/database.dart';
import '../model/floor_migrations/migration_v1_to_v2_add_bookmark_column_in_word_status_table.dart';
import '../model/floor_migrations/migration_v2_to_v3_add_tango_table.dart';
import '../utils/analytics/analytics_event_entity.dart';
import '../utils/analytics/analytics_parameters.dart';
import '../utils/analytics/firebase_analytics.dart';

class QuizScreen extends ConsumerStatefulWidget {

  const QuizScreen({Key? key}) : super(key: key);

  static void navigateTo(BuildContext context) {
    Navigator.push<void>(context, MaterialPageRoute(
      builder: (context) {
        return const QuizScreen();
      },
    ),);
  }

  static void navigateReplacementTo(BuildContext context) {
    Navigator.pushReplacement<void, void>(context, MaterialPageRoute(
      builder: (context) {
        return const QuizScreen();
      },
    ),);
  }

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int currentIndex = 0;
  bool allCardsFinished = false;
  final _cardHeight = 100.0;
  AppDatabase? database;
  StreamController<ErrorAnimationType>? errorController;
  String currentText = '';
  Map<int, String> randomText = {};
  List<(int, String)> inputtedTextList = [];
  List<(int, int)> randomAxisSize = [];
  PinCodeTextField? pinCodeTextField;
  TextEditingController? pinCodeTextFieldController;
  CountdownTimerController? countDownController;
  final baseQuestionTime = 1000 * 20;
  late int endTime = DateTime.now().millisecondsSinceEpoch + baseQuestionTime;
  final questionExplanation = '日本語に適するインドネシア語を入力してください';
  String hintText = '';
  bool isAlreadyOpenHint = false;
  bool isCheckingAnswer = false;
  bool isTimeOver = false;
  final _iconHeight = 20.0;
  final _iconWidth = 20.0;
  bool _isSoundOn = false;

  @override
  void initState() {
    FirebaseAnalyticsUtils.screenTrack(AnalyticsScreen.quiz);
    initializeDB();
    initializeSoundSetting();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initializePinCodeTextField();
      setRandomText();
      setHintText();
    });
  }

  Future<void> initializeSoundSetting() async {
    final isSoundOn = await PreferenceKey.isSoundOn.getBool();
    if (!mounted) return;
    setState(() {
      _isSoundOn = isSoundOn;
    });
  }

  Future<void> initializeDB() async {
    final _database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2, migration2to3])
        .build();
    if (!mounted) return;
    setState(() => database = _database);
  }

  Future<void> initializePinCodeTextField() async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    await setPinCodeTextField(entity);
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
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(SizeConfig.mediumMargin),
                child: Column(
                  children: [
                    _topBarSection(),
                    const SizedBox(height: SizeConfig.smallMargin),
                    _questionTitleCard(),
                    const SizedBox(height: SizeConfig.smallMargin),
                    _questionAnswerCard(),
                    const SizedBox(height: SizeConfig.smallMargin),
                    _randomKeyboard(),
                    // _actionButton(type: WordStatusType.notRemembered),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: allCardsFinished,
            child: Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      Assets.lottie.analyzeData,
                      height: _cardHeight * 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: SizeConfig.mediumSmallMargin),
                      child: TextWidget.titleWhiteLargeBold('解答を解析中...'),
                    )
                  ],
                )
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _topBarSection() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.titleGraySmallBold('${currentIndex + 1} / ${questionAnswerList.lesson.tangos.length} 問目'),
        const SizedBox(width: SizeConfig.smallMargin),
        Visibility(
          visible: pinCodeTextField != null && questionAnswerList.lesson.isTest,
          child: CountdownTimer(
            controller: countDownController,
            endTime: endTime,
          ),
        ),
        const Spacer(),
        IconButton(
            onPressed: () {
              analytics(FlushCardItem.back);
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close,
              color: ColorConfig.bgGrey,
              size: SizeConfig.largeSmallMargin,
            ),),
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
        tango: questionAnswerList.lesson.tangos[currentIndex],);
  }

  Widget _questionAnswerCard() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    return Card(
      child: Container(
        padding: const EdgeInsets.all(SizeConfig.mediumSmallMargin),
        child: Column(
          children: [
            TextWidget.titleGrayMediumBold(questionExplanation, maxLines: 2),
            const SizedBox(height: SizeConfig.smallestMargin),
            TextWidget.titleGraySmallest(
                'ヒント (${entity.indonesian?.split(' ').length}語)', maxLines: 2),
            TextWidget.titleGraySmallest(
                hintText, maxLines: 2),
            _separater(),
            if (pinCodeTextField != null) pinCodeTextField!,
            const SizedBox(height: SizeConfig.smallestMargin),
            _actionItems(),
          ],
        ),
      ),
    );
  }

  Widget _actionItems() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    return Visibility(
      visible: pinCodeTextField != null,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            _actionButton(
                image: Assets.png.lightBulb,
                title: 'hint',
                onTap: isAlreadyOpenHint || entity.indonesian!.length <= 3
                    ? null : () async {
                      openHintMore();
                    }
            ),
            _actionButton(
                image: Assets.png.skipNext,
                title: 'skip',
                onTap: () async {
                  countDownController?.disposeTimer();
                  await wrongAnswerAction(entity);
                }
            ),
            _actionButton(
                image: Assets.png.backOne,
                title: 'back',
                onTap: currentText.length == 0 ? null : () async {
                  logger.d('back button currentText: $currentText');
                  final removedLastText = currentText.removeLast();
                  logger.d('back button tapped: $removedLastText');
                  if (!mounted) return;
                  setState(() {
                    currentText = removedLastText;
                    pinCodeTextFieldController?.text = removedLastText;
                    inputtedTextList.removeLast();
                  });
                }
            ),
            _actionButton(
                image: Assets.png.delete,
                title: 'delete',
                onTap: currentText.length == 0 ? null : () async {
                  if (!mounted) return;
                  setState(() {
                    currentText = '';
                    pinCodeTextFieldController?.text = '';
                    inputtedTextList = [];
                  });
                }
            )
          ],
        ),
      ),
    );
  }

  Future<void> _answer(String input, {required TangoEntity entity}) async {
    if (!mounted) return;
    setState(() => isCheckingAnswer = true);
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    if (entity.indonesian!.toLowerCase() == input.toLowerCase()) {
      try {
        final remainTime = endTime - DateTime.now().millisecondsSinceEpoch;
        await registerWordStatus(isCorrect: true);
        await registerActivity();
        final result = QuizResult()
          ..entity = entity
          ..isCorrect = true
          ..isUsedHint = isAlreadyOpenHint
          ..answerTime = baseQuestionTime - remainTime;
        ref.read(tangoListControllerProvider.notifier).addQuizResult(result);
        await showTrueFalseDialog(
            isTrue: true, entity: entity, remainTime: remainTime);
        await getNextCard();
      } catch (e, s) {
        log('failed to go next question', error: e);
        await FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
        await getNextCard();
      }
    } else {
      errorController?.add(ErrorAnimationType.shake);
      if (_isSoundOn) {
        unawaited(AudioPlayer().play(AssetSource('sounds/Quiz-ng-mid.mp3')));
      }
      if (isTimeOver) {
        wrongAnswerAction(entity);
      }
    }
    if (!mounted) return;
    setState(() => isCheckingAnswer = false);
  }

  Widget _flashCard({
    required String title,
    required TangoEntity tango,
    bool isFront = true,
  }) {
    return Card(
      child: SizedBox(
          height: _cardHeight,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextWidget.titleRedMedium(title),
              Flexible(
                child: TextWidget.titleBlackLargestBold(
                  isFront ? tango.japanese! : tango.indonesian!, maxLines: 2,),
              ),
            ],
          ),
      ),
    );
  }

  Widget _separater() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SizeConfig.smallMargin),
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
          child: SizedBox(
            height: _cardHeight,
            width: double.infinity,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextWidget.titleRedMedium(isJapanese ? '日本語' : 'インドネシア語'),
                  const ShimmerWidget.rectangular(height: 40, width: 240,),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> registerWordStatus({required bool isCorrect}) async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final currentTango = questionAnswerList.lesson.tangos[currentIndex];

    final wordStatusDao = database?.wordStatusDao;
    final wordStatus =
      await wordStatusDao?.findWordStatusById(currentTango.id!);
    if (wordStatus != null) {
      if (isCorrect) {
        if (isAlreadyOpenHint) {
          await wordStatusDao?.updateWordStatus(
              wordStatus..status = WordStatusType.remembered.id);
        } else {
          if (wordStatus.status == WordStatusType.remembered.id
              || wordStatus.status == WordStatusType.perfectRemembered.id) {
            await wordStatusDao?.updateWordStatus(
                wordStatus..status = WordStatusType.perfectRemembered.id);
          } else {
            await wordStatusDao?.updateWordStatus(
                wordStatus..status = WordStatusType.remembered.id);
          }
        }
      } else {
        await wordStatusDao?.updateWordStatus(
            wordStatus..status = WordStatusType.notRemembered.id);
      }
    } else {
      if (isCorrect) {
        await wordStatusDao?.insertWordStatus(
            WordStatus(
                wordId: currentTango.id!,
                status: WordStatusType.remembered.id));
      } else {
        await wordStatusDao?.insertWordStatus(
            WordStatus(
                wordId: currentTango.id!,
                status: WordStatusType.notRemembered.id));
      }
    }
  }

  Future<void> registerActivity() async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final currentTango = questionAnswerList.lesson.tangos[currentIndex];

    final activityDao = database?.activityDao;
    final now = Utils.dateTimeToString(DateTime.now());
    await activityDao?.insertActivity(
        Activity(date: now, wordId: currentTango.id!));
  }

  Future<void> getNextCard() async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.length <= currentIndex + 1) {
      if (!mounted) return;
      setState(() => allCardsFinished = true);
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      if (questionAnswerList.lesson.isTest) {
        CompletionTodayTestScreen.navigateTo(context);
      } else {
        CompletionScreen.navigateTo(context);
      }
      return;
    }
    if (!mounted) return;
    setState(() {
      currentText = '';
      randomText = {};
      inputtedTextList = [];
      randomAxisSize = [];
      hintText = '';
      currentIndex++;
    });
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    await setPinCodeTextField(entity);
    setRandomText();
    setHintText();
  }

  void analytics(FlushCardItem item, {String? others = ''}) {
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

  Future<void> setPinCodeTextField(TangoEntity entity) async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    countDownController?.disposeTimer();
    if (!mounted) return;
    setState(() {
      pinCodeTextField = null;
      errorController?.close();
      errorController = null;
      countDownController = null;
      pinCodeTextFieldController = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;
    if (questionAnswerList.lesson.isTest) {
      setCountDownController(entity: entity);
    }
    final pinHeight = getPinHeight(entity.indonesian?.length ?? 0);
    final pinWidth = getPinWidth(entity.indonesian?.length ?? 0);
    final fontSize = getFontSize(entity.indonesian?.length ?? 0);
    if (!mounted) return;
    setState(() {
      errorController = StreamController<ErrorAnimationType>();
      pinCodeTextFieldController = TextEditingController();
      pinCodeTextField = PinCodeTextField(
        length: entity.indonesian?.length ?? 0,
        animationType: AnimationType.fade,
        autoFocus: false,
        pinTheme: PinTheme(
          shape: PinCodeFieldShape.box,
          borderRadius: BorderRadius.circular(5),
          fieldHeight: pinHeight,
          fieldWidth: pinWidth,
          activeFillColor: Colors.white,
          activeColor: ColorConfig.green,
          inactiveColor: ColorConfig.green,
          inactiveFillColor: Colors.white,
          selectedColor: ColorConfig.primaryRed900,
          selectedFillColor: Colors.white,
        ),
        textStyle: TextStyle(fontSize: fontSize),
        animationDuration: const Duration(milliseconds: 300),
        enableActiveFill: true,
        errorAnimationController: errorController,
        focusNode: AlwaysDisabledFocusNode(),
        controller: pinCodeTextFieldController,
        onCompleted: (v) {
          logger.d(v);
          _answer(v, entity: entity);
        },
        appContext: context,
      );
    });
  }
  
  double getPinHeight(int length) {
    if (length < 8) {
      return 40;
    } else if (length < 10) {
      return 36;
    } else if (length < 12) {
      return 32;
    } else if (length < 16) {
      return 28;
    } else {
      return 24;
    }
  }

  double getPinWidth(int length) {
    if (length < 8) {
      return 30;
    } else if (length < 10) {
      return 26;
    } else if (length < 12) {
      return 22;
    } else if (length < 16) {
      return 18;
    } else {
      return 15;
    }
  }

  double getFontSize(int length) {
    if (length < 8) {
      return 16;
    } else if (length < 10) {
      return 15;
    } else if (length < 12) {
      return 13;
    } else if (length < 16) {
      return 11;
    } else {
      return 9.5;
    }
  }

  void setCountDownController({required TangoEntity entity}) {
    if (!mounted) return;
    setState(() {
      endTime = DateTime.now().millisecondsSinceEpoch + baseQuestionTime + 500;
      countDownController = CountdownTimerController(
        endTime: endTime,
        onEnd: () async {
          await wrongAnswerAction(entity);
        },
      );
    });
  }

  Future<void> showTrueFalseDialog({
    required bool isTrue,
    required TangoEntity entity,
    int? remainTime,
  }) async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (_isSoundOn) {
      if (isTrue) {
        unawaited(AudioPlayer().play(AssetSource('sounds/Quiz-ok-mid.mp3')));
      } else {
        unawaited(AudioPlayer().play(AssetSource('sounds/Quiz-ng-mid.mp3')));
      }
    }
    unawaited(showGeneralDialog(
        context: context,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 300),
        barrierColor: Colors.black.withOpacity(0.5),
        pageBuilder: (
            BuildContext context,
            Animation animation,
            Animation secondaryAnimation
            ) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  isTrue ? Assets.lottie.checkGreen : Assets.lottie.crossRed,
                  height: _cardHeight,
                ),
                Padding(
                  padding: const EdgeInsets.all(SizeConfig.mediumMargin),
                  child: _wordDetailCard(entity),
                ),
              ],
            ),
          );
        },
    ),);
    await Future<void>.delayed(const Duration(seconds: 3));
    Navigator.of(context).pop();
  }

  Widget _actionButton({
    required AssetGenImage image,
    required String title,
    AsyncCallback? onTap,
  }) {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];

    return Visibility(
      visible: pinCodeTextField != null,
      child: WaitableElevatedButton(
        child: SizedBox(
            height: 56,
            width: 56,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                image.image(height: 24),
                TextWidget.titleGraySmallest(title),
              ],
            ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: EdgeInsets.zero,
          shape: const CircleBorder(),
        ),
        onPressed: onTap,
      ),
    );
  }

  Future<void> wrongAnswerAction(TangoEntity entity) async {
    if (isCheckingAnswer) {
      if (!mounted) return;
      setState(() => isTimeOver = true);
    } else {
      try {
        await registerWordStatus(isCorrect: false);
        await registerActivity();
        await showTrueFalseDialog(isTrue: false, entity: entity);
        final result = QuizResult()
          ..entity = entity
          ..isCorrect = false;
        ref.read(tangoListControllerProvider.notifier).addQuizResult(result);
        await getNextCard();
        if (!mounted) return;
        setState(() => isTimeOver = false);
      } catch (e, s) {
        log('failed to go next question', error: e);
        await FirebaseCrashlytics.instance.recordError(e, s, fatal: true);
        final result = QuizResult()
          ..entity = entity
          ..isCorrect = false;
        ref.read(tangoListControllerProvider.notifier).addQuizResult(result);
        await getNextCard();
        if (!mounted) return;
        setState(() => isTimeOver = false);
      }
    }
  }

  Widget _randomKeyboard() {
    const crossAxisCount = 16;
    final basicSideLength =
        (MediaQuery.of(context).size.width - (SizeConfig.mediumMargin * 2))
            / crossAxisCount;

    return StaggeredGrid.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: randomText.map<int, Widget>((i,e) {
        final randomCrossAxisCellCount = randomAxisSize[i].$1;
        final randomMainAxisCellCount = randomAxisSize[i].$2;
        final isNotUsed = inputtedTextList
            .firstWhereOrNull((e) => e.$1 == i) == null;
        final isLargeButton = math.min(randomMainAxisCellCount, randomCrossAxisCellCount) >= 3;
        final needFixedPosition =
          (randomMainAxisCellCount == 2 && randomCrossAxisCellCount == 1)
          || (randomMainAxisCellCount == 1 && randomCrossAxisCellCount == 1);
        return MapEntry(
          i,
          Visibility(
            visible: pinCodeTextField != null,
            child: StaggeredGridTile.count(
              crossAxisCellCount: randomCrossAxisCellCount,
              mainAxisCellCount: randomMainAxisCellCount,
              child: SizedBox(
                width: basicSideLength * math.min(
                    randomCrossAxisCellCount, randomMainAxisCellCount),
                height: basicSideLength * math.min(
                    randomCrossAxisCellCount, randomMainAxisCellCount),
                child: WaitableElevatedButton(
                  child: Align(
                    alignment: Alignment.center,
                    child: isLargeButton
                        ? TextWidget
                          .titleGrayLargestBold(e == ' ' ? '␣' : e)
                        : TextWidget
                          .titleGrayMediumBold(e == ' ' ? '␣' : e),
                  ),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: ColorConfig.fontGrey,
                    backgroundColor: Colors.white,
                    elevation: 8,
                    shape: const CircleBorder(),
                  ),
                  onPressed: isNotUsed ? () async {
                    setState(() {
                      pinCodeTextFieldController?.text += e;
                      currentText += e;
                      inputtedTextList.add((i, e));
                    });
                  } : null,
                ),
              ),
            ),
          ),
        );
      }).values.toList(),
    );
  }

  void setRandomText() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    final shuffledTextList = entity.indonesian!.shuffled.split('');
    final rand = math.Random();
    final randomAxisList = shuffledTextList.map((_) {
      final randomCrossAxisCellCount = rand.nextInt(2) + 3;
      final randomMainAxisCellCount = rand.nextInt(3) + 2;
      return (randomCrossAxisCellCount, randomMainAxisCellCount);
    }).toList();
    setState(() {
      randomText = shuffledTextList.asMap();
      randomAxisSize = randomAxisList;
    });
  }

  void setHintText() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    setState(() {
      isAlreadyOpenHint = false;
      hintText = entity.indonesian!.replaceAll(RegExp(r'[a-zA-Z]'), '*');
    });
  }

  void openHintMore() {
    if (isAlreadyOpenHint) {
      return;
    }
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    final textLength = entity.indonesian!.length;
    final openHintPercentage = textLength <= 8
        ? 0.3 : textLength <= 12 ? 0.4 : 0.5;
    if (textLength <= 3) {
      return;
    } else {
      final rand = math.Random();
      final openTextCount = (textLength * openHintPercentage).ceil();
      final randomList =
        List.generate(textLength, (i)=> i)..shuffle();
      var currentHintText = hintText.split('');
      for (var i = 0; i < openTextCount; i++) {
        currentHintText[randomList[i]] = entity.indonesian![randomList[i]];
      }
      setState(() {
        hintText = currentHintText.join();
        isAlreadyOpenHint = true;
      });
    }
  }

  Widget _wordDetailCard(TangoEntity entity) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(SizeConfig.mediumSmallMargin),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _partOfSpeech(entity),
              const SizedBox(height: SizeConfig.smallMargin),
              _indonesian(entity),
              const SizedBox(height: SizeConfig.smallestMargin),
              _separater(),
              _japanese(entity),
              const SizedBox(height: SizeConfig.smallMargin),
              _english(entity),
              const SizedBox(height: SizeConfig.smallMargin),
              _exampleHeader(entity),
              const SizedBox(height: SizeConfig.smallestMargin),
              _example(entity),
              const SizedBox(height: SizeConfig.smallestMargin),
              _exampleJp(entity),
              const SizedBox(height: SizeConfig.smallestMargin),
              _descriptionHeader(entity),
              const SizedBox(height: SizeConfig.smallestMargin),
              _description(entity),
              const SizedBox(height: SizeConfig.smallestMargin),
            ],
          ),
        ),
      ),
    );
  }

  Widget _partOfSpeech(TangoEntity entity) {
    return Row(
      children: [
        TextWidget.titleWhiteSmallBoldWithBackGround(PartOfSpeechExt.intToPartOfSpeech(value: entity.partOfSpeech!).title),
      ],
    );
  }

  Widget _indonesian(TangoEntity entity) {
    return Row(
      children: [
        Assets.png.indonesia64.image(height: _iconHeight, width: _iconWidth),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(
          child: TextWidget.titleBlackMediumBold(
            entity.indonesian!,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _japanese(TangoEntity entity) {
    return Row(
      children: [
        Assets.png.japanFuji64.image(height: _iconHeight, width: _iconWidth),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(
          child: TextWidget.titleGrayMediumBold(
            entity.japanese!,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _english(TangoEntity entity) {
    return Row(
      children: [
        Assets.png.english64.image(height: _iconHeight, width: _iconWidth),
        const SizedBox(width: SizeConfig.mediumSmallMargin),
        Flexible(
          child: TextWidget.titleGrayMediumSmallBold(
            entity.english!,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _exampleHeader(TangoEntity entity) {
    return Visibility(
      visible: entity.description == null || entity.description == '',
      child: Row(
        children: [
          TextWidget.titleRedMedium('例文'),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          Flexible(child: _separater()),
        ],
      ),
    );
  }

  Widget _descriptionHeader(TangoEntity entity) {
    return Visibility(
      visible: entity.description != null && entity.description != '',
      child: Row(
        children: [
          TextWidget.titleRedMedium('豆知識'),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          Flexible(child: _separater()),
        ],
      ),
    );
  }

  Widget _example(TangoEntity entity) {
    return Visibility(
      visible: entity.description == null || entity.description == '',
      child: Row(
        children: [
          Assets.png.example64.image(height: _iconHeight, width: _iconWidth),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          Flexible(
            child: TextWidget.titleBlackMediumBold(
              entity.example!,
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _exampleJp(TangoEntity entity) {
    return Visibility(
      visible: entity.description == null || entity.description == '',
      child: Row(
        children: [
          Assets.png.japan64.image(height: _iconHeight, width: _iconWidth),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          Flexible(
            child: TextWidget.titleGrayMediumSmallBold(
              entity.exampleJp!,
              maxLines: 5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _description(TangoEntity entity) {
    return Visibility(
      visible: entity.description != null && entity.description != '',
      child: Row(
        children: [
          Assets.png.infoNotes.image(height: _iconHeight, width: _iconWidth),
          const SizedBox(width: SizeConfig.mediumSmallMargin),
          Flexible(
            child: TextWidget.titleGrayMediumSmallBold(
              entity.description ?? '',
              maxLines: 10,
            ),
          ),
        ],
      ),
    );
  }
}
