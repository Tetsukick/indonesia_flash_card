import 'package:indonesia_flash_card/gen/assets.gen.dart';

enum FrequencyGroup {
  highest300,
  high500,
  high1000,
}

extension FrequencyGroupExt on FrequencyGroup {
  int get rangeFactor {
    switch (this) {
      case FrequencyGroup.highest300:
        return 300;
      case FrequencyGroup.high500:
        return 800;
      case FrequencyGroup.high1000:
        return 1800;
    }
  }

  String get title {
    switch (this) {
      case FrequencyGroup.highest300:
        return '最頻出300';
      case FrequencyGroup.high500:
        return '高頻出500';
      case FrequencyGroup.high1000:
        return '中頻出1000';
    }
  }

  SvgGenImage get svg {
    switch (this) {
      case FrequencyGroup.highest300:
        return Assets.svg.easy;
      case FrequencyGroup.high500:
        return Assets.svg.bear;
      case FrequencyGroup.high1000:
        return Assets.svg.difficult2;
    }
  }
}