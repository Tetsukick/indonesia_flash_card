import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/model/floor_entity/activity.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/word_status_type.dart';
import 'package:indonesia_flash_card/screen/completion_screen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:indonesia_flash_card/utils/shimmer.dart';
import 'package:indonesia_flash_card/utils/utils.dart';
import 'package:lottie/lottie.dart';

import '../model/floor_database/database.dart';

class FlashCardScreen extends ConsumerStatefulWidget {
  static navigateTo(context) {
    Navigator.push(context, MaterialPageRoute(
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
  final _cardHeight = 160.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      body: SafeArea(
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
    );
  }

  Widget _topBarSection() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextWidget.titleGraySmallBold('${currentIndex + 1} / ${questionAnswerList.lesson.tangos.length} 問目'),
        IconButton(
            onPressed: () => Navigator.pop(context),
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
    return _flashCard(
        title: 'インドネシア語',
        data: questionAnswerList.lesson.tangos[currentIndex].indonesian ?? '');
  }

  Widget _flashCardBack() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.isEmpty) {
      return _shimmerFlashCard(isTappable: false);
    } else if (!cardFlipped) {
      return _shimmerFlashCard(isTappable: true);
    }
    return _flashCard(
        title: '日本語',
        data: questionAnswerList.lesson.tangos[currentIndex].japanese ?? '');
  }

  Widget _flashCard({required String title, required String data}) {
    return Card(
      child: Container(
        height: _cardHeight,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextWidget.titleRedMedium(title),
              TextWidget.titleBlackLargeBold(data)
            ],
          ),
        ),
      ),
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
              onPressed: () => setState(() => cardFlipped = true),
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
          await registerWordStatus(type: type);
          await registerActivity();
          getNextCard();
        },
      ),
    );
  }

  Future<void> registerWordStatus({required WordStatusType type}) async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final currentTango = questionAnswerList.lesson.tangos[currentIndex];
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

    final wordStatusDao = database.wordStatusDao;
    final wordStatus = await wordStatusDao.findWordStatusById(currentTango.id!);
    if (wordStatus != null) {
      await wordStatusDao.updateWordStatusById(type.id, wordStatus.wordId);
    } else {
      await wordStatusDao.insertWordStatus(WordStatus(wordId: currentTango.id!, status: type.id));
    }
  }

  Future<void> registerActivity() async {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    final currentTango = questionAnswerList.lesson.tangos[currentIndex];
    final database = await $FloorAppDatabase.databaseBuilder('app_database.db').build();

    final activityDao = database.activityDao;
    final now = Utils.dateTimeToString(DateTime.now());
    await activityDao.insertActivity(Activity(date: now, wordId: currentTango.id!));
  }

  void getNextCard() {
    final questionAnswerList = ref.watch(tangoListControllerProvider);
    if (questionAnswerList.lesson.tangos.length <= currentIndex + 1) {
      setState(() => allCardsFinished = true);
      CompletionScreen.navigateTo(context);
      return;
    }
    setState(() {
      cardFlipped = false;
      currentIndex++;
    });
  }
}
