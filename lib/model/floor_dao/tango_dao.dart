import 'package:floor/floor.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';

@dao
abstract class TangoDao {
  @Query('SELECT * FROM TangoEntity ORDER BY indonesian ASC LIMIT :offset,:limit')
  Future<List<TangoEntity>> getAllTangoList(int offset, int limit);

  @Query('SELECT * FROM TangoEntity WHERE category = :categoryId ORDER BY indonesian ASC')
  Future<List<TangoEntity>> getTangoListByCategory(int categoryId);

  @Query('SELECT * FROM TangoEntity WHERE partOfSpeech = :partOfSpeech ORDER BY indonesian ASC')
  Future<List<TangoEntity>> getTangoListByPartOfSpeech(int partOfSpeech);

  @Query('SELECT * FROM TangoEntity WHERE level >= :levelMin AND level <= :levelMax ORDER BY indonesian ASC')
  Future<List<TangoEntity>> getTangoListByLevel(int levelMin, int levelMax);

  @Query('SELECT * FROM TangoEntity WHERE rankFrequency >= :frequencyFactorMin AND rankFrequency <= :frequencyFactorMax ORDER BY indonesian ASC')
  Future<List<TangoEntity>> getTangoListByFrequency(int frequencyFactorMin, int frequencyFactorMax);

  @update
  Future<void> updateTangoEntity(TangoEntity tango);

  @insert
  Future<void> insertTangoEntity(TangoEntity tango);

  @Query('DELETE FROM TangoEntity')
  Future<void> deleteAllTango();
}