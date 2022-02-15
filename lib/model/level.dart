import 'package:indonesia_flash_card/gen/assets.gen.dart';

enum LevelGroup {
  superEasy,
  easy,
  medium,
  hard,
  superHard
}

extension LevelGroupExt on LevelGroup {
  List<int> get range {
    switch (this) {
      case LevelGroup.superEasy:
        return [1,2];
      case LevelGroup.easy:
        return [3,4];
      case LevelGroup.medium:
        return [5,6];
      case LevelGroup.hard:
        return [7,8];
      case LevelGroup.superHard:
        return [9,10];
    }
  }

  String get title {
    switch (this) {
      case LevelGroup.superEasy:
        return '超初級';
      case LevelGroup.easy:
        return '初級';
      case LevelGroup.medium:
        return '中級';
      case LevelGroup.hard:
        return '上級';
      case LevelGroup.superHard:
        return '超上級';
    }
  }

  SvgGenImage get svg {
    switch (this) {
      case LevelGroup.superEasy:
        return Assets.svg.cat;
      case LevelGroup.easy:
        return Assets.svg.easy;
      case LevelGroup.medium:
        return Assets.svg.world;
      case LevelGroup.hard:
        return Assets.svg.difficult;
      case LevelGroup.superHard:
        return Assets.svg.ufo;
    }
  }
}