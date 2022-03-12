import 'package:indonesia_flash_card/gen/assets.gen.dart';

enum Rank {
  E_minus,
  E,
  E_plus,
  D_minus,
  D,
  D_plus,
  C_minus,
  C,
  C_plus,
  B_minus,
  B,
  B_plus,
  A,
  A_plus,
  A_plusPlus,
}

extension RankExt on Rank {
  String get title {
    switch (this) {
      case Rank.E_minus:
        return 'E-級';
      case Rank.E:
        return 'E級';
      case Rank.E_plus:
        return 'E+級';
      case Rank.D_minus:
        return 'D-級';
      case Rank.D:
        return 'D級';
      case Rank.D_plus:
        return 'D+級';
      case Rank.C_minus:
        return 'C-級';
      case Rank.C:
        return 'C級';
      case Rank.C_plus:
        return 'C+級';
      case Rank.B_minus:
        return 'B-級';
      case Rank.B:
        return 'B級';
      case Rank.B_plus:
        return 'B+級';
      case Rank.A:
        return 'A級';
      case Rank.A_plus:
        return '特A級';
      case Rank.A_plusPlus:
        return '特特A級';
    }
  }

  AssetGenImage get img {
    switch (this) {
      case Rank.E_minus:
        return Assets.dot.friedEgg;
      case Rank.E:
        return Assets.dot.dashimaki;
      case Rank.E_plus:
        return Assets.dot.omurice;
      case Rank.D_minus:
        return Assets.dot.hiyoko;
      case Rank.D:
        return Assets.dot.niwatoriHalfEgg;
      case Rank.D_plus:
        return Assets.dot.niwatoriFront;
      case Rank.C_minus:
        return Assets.dot.niwatoriCuteEye;
      case Rank.C:
        return Assets.dot.niwatoriBreak;
      case Rank.C_plus:
        return Assets.dot.niwatoriRun;
      case Rank.B_minus:
        return Assets.dot.toriKaraage;
      case Rank.B:
        return Assets.dot.yakitori;
      case Rank.B_plus:
        return Assets.dot.penginCute;
      case Rank.A:
        return Assets.dot.eagleStrong;
      case Rank.A_plus:
        return Assets.dot.monster;
      case Rank.A_plusPlus:
        return Assets.dot.monsterStrong;
    }
  }

  static Rank doubleToRank({required double score}) {
    if (score <= 100) {
      return Rank.E_minus;
    } else if (score <= 130) {
      return Rank.E;
    } else if (score <= 150) {
      return Rank.E_plus;
    } else if (score <= 180) {
      return Rank.D_minus;
    } else if (score <= 200) {
      return Rank.D;
    } else if (score <= 230) {
      return Rank.D_plus;
    } else if (score <= 250) {
      return Rank.C_minus;
    } else if (score <= 280) {
      return Rank.C;
    } else if (score <= 300) {
      return Rank.C_plus;
    } else if (score <= 340) {
      return Rank.B_minus;
    } else if (score <= 380) {
      return Rank.B;
    } else if (score <= 420) {
      return Rank.B_plus;
    } else if (score <= 460) {
      return Rank.A;
    } else if (score <= 500) {
      return Rank.A_plus;
    } else {
      return Rank.A_plusPlus;
    }
  }
}