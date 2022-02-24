import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:indonesia_flash_card/config/color_config.dart';
import 'package:indonesia_flash_card/domain/tango_list_service.dart';
import 'package:indonesia_flash_card/screen/flush_card_screen.dart';
import 'package:indonesia_flash_card/utils/common_text_widget.dart';
import 'package:lottie/lottie.dart';

import '../config/size_config.dart';
import '../gen/assets.gen.dart';

class CompletionScreen extends ConsumerStatefulWidget {
  const CompletionScreen({Key? key}) : super(key: key);

  static navigateTo(context) {
    Navigator.pushReplacement(context, MaterialPageRoute(
      builder: (context) {
        return CompletionScreen();
      },
    ));
  }

  @override
  _CompletionScreenState createState() => _CompletionScreenState();
}

class _CompletionScreenState extends ConsumerState<CompletionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      body: Container(
        padding: EdgeInsets.all(SizeConfig.mediumSmallMargin),
        height: double.infinity,
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Assets.gif.birBintangKanpai.image(height: 150),
            const SizedBox(height: SizeConfig.mediumSmallMargin),
            TextWidget.titleGraySmallBold('おつかれさまでした!'),
            const SizedBox(height: SizeConfig.smallMargin),
            _button(
              onPressed: () {
                ref.read(tangoListControllerProvider.notifier).resetLessonsData();
                FlashCardScreen.navigateReplacementTo(context);
              },
              img: Assets.png.continue128,
              title: '同じ設定で継続'
            ),
            const SizedBox(height: SizeConfig.smallMargin),
            _button(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              img: Assets.png.home128,
              title: 'トップに戻る'
            ),
          ],
        ),
      ),
    );
  }

  Widget _button({required VoidCallback? onPressed, required AssetGenImage img, required String title}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: ColorConfig.primaryRed900,
        shape: const StadiumBorder(),
      ),
      child: SizedBox(
        height: 50,
        width: 160,
        child: Row(
          children: [
            img.image(height: 24, width: 24),
            const SizedBox(width: SizeConfig.mediumLargeMargin),
            TextWidget.titleRedMedium(title)
          ],
        ),
      ),
    );
  }
}
