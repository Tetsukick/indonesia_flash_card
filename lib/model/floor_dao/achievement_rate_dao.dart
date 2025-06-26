
import 'package:floor/floor.dart';
import 'package:indonesia_flash_card/model/floor_entity/achievement_rate.dart';

@dao
abstract class AchievementRateDao {
  @Query('SELECT * FROM AchievementRate')
  Future<List<AchievementRate>> findAllAchievementRates();

  @Query('SELECT * FROM AchievementRate WHERE id = :id')
  Future<AchievementRate?> findAchievementRateById(String id);

  @insert
  Future<void> insertAchievementRate(AchievementRate achievementRate);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> upsertAchievementRate(AchievementRate achievementRate);
}
