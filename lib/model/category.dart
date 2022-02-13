import 'package:indonesia_flash_card/gen/assets.gen.dart';

enum TangoCategory {
  work,
  food,
  time,
  tool,
  building,
  money,
  unit,
  event,
  fashion,
  body,
  vehicle,
  country,
  hobby,
  other,
}

extension TangoCategoryExt on TangoCategory {
  int get id => index + 1;

  String get title {
    switch (this) {
      case TangoCategory.work:
        return '人物・職業';
      case TangoCategory.food:
        return '食べ物・飲み物';
      case TangoCategory.time:
        return '時間・曜日';
      case TangoCategory.tool:
        return '道具';
      case TangoCategory.building:
        return '建物・場所';
      case TangoCategory.money:
        return 'お金';
      case TangoCategory.unit:
        return '単位';
      case TangoCategory.event:
        return 'イベント';
      case TangoCategory.fashion:
        return '服';
      case TangoCategory.body:
        return '身体';
      case TangoCategory.vehicle:
        return '乗り物';
      case TangoCategory.country:
        return '国';
      case TangoCategory.hobby:
        return '娯楽';
      case TangoCategory.other:
        return 'その他';
    }
  }

  SvgGenImage get svg {
    switch (this) {
      case TangoCategory.work:
        return Assets.svg.work2;
      case TangoCategory.food:
        return Assets.svg.eat;
      case TangoCategory.time:
        return Assets.svg.time2;
      case TangoCategory.tool:
        return Assets.svg.tool2;
      case TangoCategory.building:
        return Assets.svg.building2;
      case TangoCategory.money:
        return Assets.svg.money2;
      case TangoCategory.unit:
        return Assets.svg.unit2;
      case TangoCategory.event:
        return Assets.svg.event3;
      case TangoCategory.fashion:
        return Assets.svg.fashion4;
      case TangoCategory.body:
        return Assets.svg.sport2;
      case TangoCategory.vehicle:
        return Assets.svg.vehicle3;
      case TangoCategory.country:
        return Assets.svg.world2;
      case TangoCategory.hobby:
        return Assets.svg.shodou;
      case TangoCategory.other:
        return Assets.svg.islam2;
    }
  }

  static TangoCategory intToCategory({required int value}) {
    switch (value) {
      case 1:
        return TangoCategory.work;
      case 2:
        return TangoCategory.food;
      case 3:
        return TangoCategory.time;
      case 4:
        return TangoCategory.tool;
      case 5:
        return TangoCategory.building;
      case 6:
        return TangoCategory.money;
      case 7:
        return TangoCategory.unit;
      case 8:
        return TangoCategory.event;
      case 9:
        return TangoCategory.fashion;
      case 10:
        return TangoCategory.body;
      case 11:
        return TangoCategory.vehicle;
      case 12:
        return TangoCategory.country;
      case 13:
        return TangoCategory.hobby;
      default:
        return TangoCategory.other;
    }
  }
}