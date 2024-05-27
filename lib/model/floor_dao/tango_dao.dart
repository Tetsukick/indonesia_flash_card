import 'package:floor/floor.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';

@dao
abstract class TangoDao {
  @Query('SELECT * FROM TangoEntity ORDER BY indonesian ASC LIMIT :offset,:limit')
  Future<List<TangoEntity>> getAllTangoList(int offset, int limit);

  //   NEED manually fix in database.g.dart like bellow. (only for count SQL)
  //   @override
  //   Future<int?> getCountTangoList() async {
  //     return _queryAdapter.query('SELECT COUNT(*) FROM TangoEntity',
  //         mapper: (Map<String, Object?> row) => row['COUNT(*)'] as int);
  //   }
  @Query('SELECT COUNT(*) FROM TangoEntity')
  Future<int?> getCountTangoList();

  @Query('SELECT * FROM TangoEntity WHERE LOWER(indonesian) = :name ORDER BY indonesian ASC')
  Future<List<TangoEntity>> getTangoListByIndonesian(String name);

  @Query('SELECT * FROM TangoEntity WHERE LOWER(indonesian) like :search ORDER BY indonesian ASC')
  Future<List<TangoEntity>> getTangoListByLikeIndonesian(String search);

  @Query('SELECT * FROM TangoEntity WHERE LOWER(japanese) like :search ORDER BY indonesian ASC')
  Future<List<TangoEntity>> getTangoListByLikeJapanese(String search);

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