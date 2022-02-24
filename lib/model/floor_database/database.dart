import 'dart:async';
import 'package:floor/floor.dart';
import 'package:indonesia_flash_card/model/floor_dao/activity_dao.dart';
import 'package:indonesia_flash_card/model/floor_dao/word_status_dao.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';
import 'package:indonesia_flash_card/model/floor_entity/activity.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'database.g.dart';

@Database(version: 2, entities: [WordStatus, Activity])
abstract class AppDatabase extends FloorDatabase {
  WordStatusDao get wordStatusDao;
  ActivityDao get activityDao;
}