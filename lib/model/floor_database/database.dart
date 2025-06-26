// Dart imports:
import 'dart:async';

// Package imports:
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

// Project imports:
import 'package:indonesia_flash_card/model/floor_dao/activity_dao.dart';
import 'package:indonesia_flash_card/model/floor_dao/achievement_rate_dao.dart';
import 'package:indonesia_flash_card/model/floor_dao/tango_dao.dart';
import 'package:indonesia_flash_card/model/floor_dao/word_status_dao.dart';
import 'package:indonesia_flash_card/model/floor_entity/activity.dart';
import 'package:indonesia_flash_card/model/floor_entity/achievement_rate.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';

part 'database.g.dart';

@Database(version: 4, entities: [WordStatus, Activity, TangoEntity, AchievementRate])
abstract class AppDatabase extends FloorDatabase {
  WordStatusDao get wordStatusDao;
  ActivityDao get activityDao;
  TangoDao get tangoDao;
  AchievementRateDao get achievementRateDao;
}
