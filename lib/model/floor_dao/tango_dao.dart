import 'package:floor/floor.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';

import '../category.dart';
import '../frequency.dart';
import '../level.dart';
import '../part_of_speech.dart';
import '../sort_type.dart';
import '../word_status_type.dart';

@dao
abstract class TangoDao {
  @Query('SELECT * FROM TangoEntity ORDER BY indonesian ASC LIMIT :offset,:limit')
  Future<List<TangoEntity>> getAllTangoList({int offset = 0, int limit = 100});

  @update
  Future<void> updateTangoEntity(TangoEntity tango);

  @insert
  Future<void> insertTangoEntity(TangoEntity tango);

  @Query('DELETE * FROM TangoEntity')
  Future<void> deleteAllTango();
}