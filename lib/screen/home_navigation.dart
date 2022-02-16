import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:indonesia_flash_card/screen/lesson_selector_screen.dart';

import '../config/color_config.dart';

class HomeNavigation extends StatefulWidget {
  const HomeNavigation({Key? key}) : super(key: key);

  @override
  _HomeNavigationState createState() => _HomeNavigationState();
}

class _HomeNavigationState extends State<HomeNavigation> {
  int _page = 0;
  GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConfig.bgPinkColor,
      bottomNavigationBar: CurvedNavigationBar(
        key: _bottomNavigationKey,
        backgroundColor: ColorConfig.bgPinkColor,
        items: <Widget>[
          Icon(FontAwesomeIcons.book, size: 30),
          Icon(FontAwesomeIcons.list, size: 30),
          Icon(FontAwesomeIcons.bars, size: 30),
        ],
        onTap: (index) => setState(() => _page = index),
      ),
      body: pages(),
    );
  }

  Widget pages() {
    return LessonSelectorScreen();
  }
}
