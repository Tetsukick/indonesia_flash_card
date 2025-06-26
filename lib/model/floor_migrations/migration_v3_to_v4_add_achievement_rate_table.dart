
import 'package:floor/floor.dart';

final migration3to4 = Migration(3, 4, (database) async {
  await database.execute('CREATE TABLE IF NOT EXISTS `AchievementRate` (`id` TEXT NOT NULL, `rate` REAL NOT NULL, `updatedAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');
});
