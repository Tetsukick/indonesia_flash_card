import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/config/size_config.dart';

import '../lesson_selector_screen.dart';

class CompletionWidget extends StatelessWidget {
  final VoidCallback onPressed;
  const CompletionWidget({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Congratulations! You finished all your cards."),
        const SizedBox(height: SizeConfig.smallMargin),
        ElevatedButton(
          onPressed: onPressed,
          child: const Text("Repeat Lesson"),
        ),
        const SizedBox(height: SizeConfig.smallMargin),
        ElevatedButton(
          onPressed: () {
            LessonSelectorScreen.navigateTo(context);
          },
          child: const Text("Back to Lecture Selection"),
        )
      ],
    );
  }
}
