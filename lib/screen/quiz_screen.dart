// Dart imports:
import 'dart:async';
import 'dart:math' as math;

// Flutter imports:
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
// Package imports:
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
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
import 'package:indonesia_flash_card/model/tango_entity.dart';
import 'package:indonesia_flash_card/model/tango_master.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/screen/completion_screen.dart';
import 'package:indonesia_flash_card/screen/completion_today_test_screen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/disable_focus_node.dart';
import 'package:indonesia_flash_card/utils/logger.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';
import 'package:indonesia_flash_card/utils/shuffle_string.dart';
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
  List<String> randomText = [];
  List<(int, int)> randomAxisSize = [];
  PinCodeTextField? pinCodeTextField;
  TextEditingController? pinCodeTextFieldController;
  CountdownTimerController? countDownController;
  final baseQuestionTime = 1000 * 15;
  late int endTime = DateTime.now().millisecondsSinceEpoch + baseQuestionTime;
  final questionExplanation = '日本語に適するインドネシア語を入力してください';

  @override
  void initState() {
    FirebaseAnalyticsUtils.screenTrack(AnalyticsScreen.quiz);
    initializeDB();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      initializePinCodeTextField();
      setRandomText();
    });
  }

  Future<void> initializeDB() async {
    final _database = await $FloorAppDatabase
        .databaseBuilder(Config.dbName)
        .addMigrations([migration1to2, migration2to3])
        .build();
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
      body: SafeArea(
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
                hintText(entity.indonesian!), maxLines: 2),
            _separater(),
            if (pinCodeTextField != null) pinCodeTextField!,
          ],
        ),
      ),
    );
  }

  Future<void> _answer(String input, {required TangoEntity entity}) async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    if (entity.indonesian!.toLowerCase() == input.toLowerCase()) {
      final remainTime = endTime - DateTime.now().millisecondsSinceEpoch;
      await registerWordStatus(isCorrect: true);
      await registerActivity();
      final result = QuizResult()
        ..entity = entity
        ..isCorrect = true
        ..answerTime = baseQuestionTime - remainTime;
      ref.read(tangoListControllerProvider.notifier).addQuizResult(result);
      await showTrueFalseDialog(
          isTrue: true, entity: entity, remainTime: remainTime);
      await getNextCard();
    } else {
      errorController?.add(ErrorAnimationType.shake);
    }
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
        if (wordStatus.status == WordStatusType.remembered.id
            || wordStatus.status == WordStatusType.perfectRemembered.id) {
          await wordStatusDao?.updateWordStatus(
              wordStatus..status = WordStatusType.perfectRemembered.id);
        } else {
          await wordStatusDao?.updateWordStatus(
              wordStatus..status = WordStatusType.remembered.id);
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
      setState(() => allCardsFinished = true);
      await Future<void>.delayed(const Duration(milliseconds: 2500));
      if (questionAnswerList.lesson.isTest) {
        CompletionTodayTestScreen.navigateTo(context);
      } else {
        CompletionScreen.navigateTo(context);
      }
      return;
    }
    setState(() {
      currentText = '';
      currentIndex++;
    });
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    await setPinCodeTextField(entity);
    setRandomText();
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
    setState(() {
      pinCodeTextField = null;
      errorController?.close();
      errorController = null;
      countDownController = null;
      pinCodeTextFieldController = null;
    });

    await Future<void>.delayed(const Duration(milliseconds: 1200));

    if (questionAnswerList.lesson.isTest) {
      setCountDownController(entity);
    }
    final pinHeight = getPinHeight(entity.indonesian?.length ?? 0);
    final pinWidth = getPinWidth(entity.indonesian?.length ?? 0);
    final fontSize = getFontSize(entity.indonesian?.length ?? 0);
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
        onChanged: (value) {
          setState(() {
            currentText = value;
          });
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

  void setCountDownController(TangoEntity entity) {
    setState(() {
      endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 15 + 500;
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
                  height: _cardHeight * 2,
                ),
                Visibility(
                  visible: remainTime != null,
                    child: Padding(
                      padding: const EdgeInsets.all(
                          SizeConfig.mediumSmallMargin),
                      child: TextWidget.titleWhiteLargeBold(
                          '回答時間: ${baseQuestionTime - (remainTime ?? 0)} ms'),
                    ),
                ),
                Visibility(
                  visible: !isTrue,
                  child: _flashCard(
                    title: 'インドネシア語',
                    tango: entity,
                    isFront: false,
                  ),
                ),
              ],
            ),
          );
        },
    ),);
    await Future<void>.delayed(const Duration(seconds: 2));
    Navigator.of(context).pop();
  }

  Widget _actionButton({required WordStatusType type}) {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];

    return Visibility(
      visible: pinCodeTextField != null,
      child: Card(
        shape: const CircleBorder(),
        child: InkWell(
          child: SizedBox(
              height: 120,
              width: 120,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  type.iconLarge,
                  const SizedBox(height: SizeConfig.smallMargin),
                  TextWidget.titleGraySmallBold('パス'),
                ],
              ),
          ),
          onTap: () async {
            countDownController?.disposeTimer();
            await wrongAnswerAction(entity);
          },
        ),
      ),
    );
  }

  Future<void> wrongAnswerAction(TangoEntity entity) async {
    await registerWordStatus(isCorrect: false);
    await registerActivity();
    await showTrueFalseDialog(isTrue: false, entity: entity);
    final result = QuizResult()
      ..entity = entity
      ..isCorrect = false;
    ref.read(tangoListControllerProvider.notifier).addQuizResult(result);
    await getNextCard();
  }

  String hintText(String value) {
    return value.replaceAll(RegExp(r'[a-zA-Z]'), '*');
  }

  Widget _randomKeyboard() {

    return StaggeredGrid.count(
      crossAxisCount: 7,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      children: randomText.mapIndexed((i,e) {
        final randomCrossAxisCellCount = randomAxisSize[i].$1;
        final randomMainAxisCellCount = randomAxisSize[i].$2;
        logger.d(
            'cross: $randomCrossAxisCellCount, main: $randomMainAxisCellCount');
        return StaggeredGridTile.count(
            crossAxisCellCount: randomCrossAxisCellCount,
            mainAxisCellCount: randomMainAxisCellCount,
            child: WaitableElevatedButton(
              child: Text(e),
              style: ElevatedButton.styleFrom(
                foregroundColor: ColorConfig.fontGrey,
                backgroundColor: Colors.white,
                elevation: 16,
                shape: const CircleBorder(),
              ),
              onPressed: () async {
                setState(() {
                  pinCodeTextFieldController?.text += e;
                  currentText += e;
                });
              },
            ),

        );
      }).toList(),
    );
  }

  void setRandomText() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final entity = questionAnswerList.lesson.tangos[currentIndex];
    final shuffledTextList = entity.indonesian!.shuffled.split('');
    final rand = math.Random();
    final randomAxisList = shuffledTextList.map((_) {
      final randomCrossAxisCellCount = rand.nextInt(2) + 1;
      final randomMainAxisCellCount = rand.nextInt(2) + 1;
      return (randomCrossAxisCellCount, randomMainAxisCellCount);
    }).toList();
    setState(() {
      randomText = shuffledTextList;
      randomAxisSize = randomAxisList;
    });
  }
}
