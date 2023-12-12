import 'package:floor/floor.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';

@dao
abstract class TangoDao {
  @Query('SELECT * FROM TangoEntity ORDER BY indonesian ASC LIMIT :offset,:limit')
  Future<List<TangoEntity>> getAllTangoList({int offset = 0, int limit = 100});

  @Query('SELECT * FROM TangoEntity ORDER BY indonesian ASC WHERE category = :categoryId')
  Future<List<TangoEntity>> getTangoListByCategory({int categoryId});

  @Query('SELECT * FROM TangoEntity ORDER BY indonesian ASC WHERE partOfSpeech = :partOfSpeech')
  Future<List<TangoEntity>> getTangoListByPartOfSpeech({int partOfSpeech});

  @Query('SELECT * FROM TangoEntity ORDER BY indonesian ASC WHERE level BETWEEN :levelMin AND :levelMax')
  Future<List<TangoEntity>> getTangoListByLevel({int levelMin, int levelMax});

  @Query('SELECT * FROM TangoEntity ORDER BY indonesian ASC WHERE rankFrequency BETWEEN :frequencyFactorMin AND :frequencyFactorMax')
  Future<List<TangoEntity>> getTangoListByFrequency({int frequencyFactorMin, int frequencyFactorMax});

  @update
  Future<void> updateTangoEntity(TangoEntity tango);

  @insert
  Future<void> insertTangoEntity(TangoEntity tango);

  @Query('DELETE * FROM TangoEntity')
  Future<void> deleteAllTango();
}