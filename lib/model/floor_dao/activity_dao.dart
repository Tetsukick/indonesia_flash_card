import 'package:floor/floor.dart';
import 'package:indonesia_flash_card/model/floor_entity/activity.dart';

@dao
abstract class ActivityDao {
  @Query('SELECT * FROM Activity')
  Future<List<Activity>> findAllActivity();

  @Query('SELECT * FROM Activity WHERE wordId = :id')
  Future<List<Activity>> findActivityById(int id);

  @Query('SELECT * FROM Activity WHERE date = :date')
  Future<List<Activity>> findActivityByDate(String date);

  @insert
  Future<void> insertActivity(Activity activity);
}