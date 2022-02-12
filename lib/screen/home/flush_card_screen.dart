import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/size_config.dart';
import 'package:indonesia_flash_card/domain/flashcard_service.dart';
import 'package:indonesia_flash_card/repository/sheat_repo.dart';

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
    final questionAnswerList = ref.watch(flashCardControllerProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SizeConfig.smallestMargin),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Expanded(
          child: allCardsFinished
          ? CompletionWidget(onPressed: () {
        init = startLesson();
        })
            : IgnorePointer(
        ignoring: cardFlipped,
        child: InkWell(
          onTap: () =>
              setState(() => cardFlipped = !cardFlipped),
          child: Card(
            child: Center(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    cardFlipped
                        ? '日本語'
                        : 'インドネシア語',
                    textAlign: TextAlign.center,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        cardFlipped
                            ? questionAnswerList[currentIndex]
                            .value
                            : questionAnswerList[currentIndex]
                            .key,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    ),
    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButtonSection() {
    return Row(
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
