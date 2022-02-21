import 'package:flutter/cupertino.dart';
import 'package:indonesia_flash_card/gen/assets.gen.dart';

enum WordStatusType {
  notLearned,
  notRemembered,
  remembered,
}

extension WordStatusTypeExt on WordStatusType {
  int get id => index;

  String get title {
    switch (this) {
      case WordStatusType.notLearned:
        return '未学習';
      case WordStatusType.notRemembered:
        return '未暗記';
      case WordStatusType.remembered:
        return '暗記済み';
    }
  }

  String get actionTitle {
    switch (this) {
      case WordStatusType.notLearned:
        return '';
      case WordStatusType.notRemembered:
        return '知らない';
      case WordStatusType.remembered:
        return '覚えた';
    }
  }

  Widget get icon {
    final _height = 16.0;
    final _width = 16.0;
    switch (this) {
      case WordStatusType.notLearned:
        return Assets.png.minus128.image(height: _height, width: _width);
      case WordStatusType.notRemembered:
        return Assets.png.cancelRed128.image(height: _height, width: _width);
      case WordStatusType.remembered:
        return Assets.png.checkedGreen128.image(height: _height, width: _width);
    }
  }

  Widget get iconLarge {
    final _height = 40.0;
    final _width = 40.0;
    switch (this) {
      case WordStatusType.notLearned:
        return Assets.png.minus128.image(height: _height, width: _width);
      case WordStatusType.notRemembered:
        return Assets.png.cancelRed128.image(height: _height, width: _width);
      case WordStatusType.remembered:
        return Assets.png.checkedGreen128.image(height: _height, width: _width);
    }
  }

  static WordStatusType intToWordStatusType(int id) {
    switch (id) {
      case 0:
        return WordStatusType.notLearned;
      case 1:
        return WordStatusType.notRemembered;
      case 2:
        return WordStatusType.remembered;
      default:
        return WordStatusType.notLearned;
    }
  }
}