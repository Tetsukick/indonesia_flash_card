import 'package:floor/floor.dart';
import 'package:indonesia_flash_card/model/floor_entity/word_status.dart';

@dao
abstract class WordStatusDao {
  @Query('SELECT * FROM WordStatus')
  Future<List<WordStatus>> findAllWordStatus();

  @Query('SELECT * FROM WordStatus WHERE wordId = :id')
  Future<WordStatus?> findWordStatusById(int id);

  @update
  Future<void> updateWordStatus(WordStatus wordStatus);

  @insert
  Future<void> insertWordStatus(WordStatus wordStatus);
}