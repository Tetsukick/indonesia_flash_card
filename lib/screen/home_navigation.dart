import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';
import 'package:indonesia_flash_card/screen/dictionary_screen.dart';
import 'package:indonesia_flash_card/screen/lesson_selector_screen.dart';
import 'package:indonesia_flash_card/screen/menu_screen.dart';
import 'package:indonesia_flash_card/screen/translation_screen.dart';

import '../config/color_config.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({Key? key}) : super(key: key);

  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  final List<Widget> _pages = [
    LessonSelectorScreen(),
    DictionaryScreen(),
    TranslationScreen(),
    MenuScreen(),
  ];
  final iconWidth = 32.0;
  final iconHeight = 32.0;
  int _pageIndex = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    confirmATTStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: ColorConfig.bgPinkColor,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: ColorConfig.bgPinkColor.withOpacity(0.4),
        items: <Widget>[
          Assets.png.flashCardColor.image(width: iconWidth, height: iconHeight),
          Assets.png.dictionaryColor2.image(width: iconWidth, height: iconHeight),
          Assets.png.translation128.image(width: iconWidth, height: iconHeight),
          Assets.png.menuColor.image(width: iconWidth, height: iconHeight),
        ],
        onTap: (index) => setState(() => _pageIndex = index),
      ),
      body: SafeArea(
          bottom: false,
          child: _pages[_pageIndex]),
    );
  }

  Future<void> confirmATTStatus() async {
    if (Platform.isIOS) {
      final status = await AppTrackingTransparency.requestTrackingAuthorization();
      print('ATT Status = $status');
    }
  }
}
