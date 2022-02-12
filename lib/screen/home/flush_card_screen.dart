import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/flashcard_service.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';

import 'completion_widget.dart';

class FlushScreen extends ConsumerStatefulWidget {
  static navigateTo(context, String spreadsheetId) {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return FlushScreen(spreadsheetId: spreadsheetId);
      },
    ));
  }

  final String spreadsheetId;

  const FlushScreen({Key? key, required this.spreadsheetId}) : super(key: key);

  @override
  ConsumerState<FlushScreen> createState() => _FlushScreenState();
}

class _FlushScreenState extends ConsumerState<FlushScreen> {
  late Future<bool> init;
  int currentIndex = 0;
  bool cardFlipped = false;
  bool allCardsFinished = true;

  @override
  initState() {
    super.initState();
    init = startLesson();
  }

  Future<bool> startLesson() async {
    ref.read(flashCardControllerProvider.notifier).getQuestionsAndAnswers(SheetRepo(widget.spreadsheetId));
    setState(() {
      cardFlipped = false;
      allCardsFinished = false;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SizeConfig.mediumMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _flashCardFront(),
              _flashCardBack(),
              _actionButtonSection()
            ],
          ),
        ),
      ),
    );
  }

  Widget _flashCardFront() {
    final questionAnswerList = ref.watch(flashCardControllerProvider);
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextWidget.titleRedMedium('インドネシア語'),
            TextWidget.titleBlackLargeBold(questionAnswerList[currentIndex].key)
          ],
        ),
      ),
    );
  }

  Widget _flashCardBack() {
    final questionAnswerList = ref.watch(flashCardControllerProvider);
    return Card(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextWidget.titleRedMedium('日本語'),
            TextWidget.titleBlackLargeBold(questionAnswerList[currentIndex].value)
          ],
        ),
      ),
    );
  }

  Widget _actionButtonSection() {
    return Padding(
      padding: const EdgeInsets.all(SizeConfig.smallMargin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: getNextCard,
            icon: const Icon(Icons.cancel),
          ),
          IconButton(
            onPressed: getNextCard,
            icon: const Icon(Icons.check_circle),
          ),
        ],
      ),
    );
  }

  void getNextCard() {
    final questionAnswerList = ref.watch(flashCardControllerProvider);
    if (questionAnswerList.length <= currentIndex + 1) {
      setState(() => allCardsFinished = true);
      return;
    }
    setState(() {
      cardFlipped = false;
      currentIndex++;
    });
  }
}
