import 'package:floor/floor.dart';

final migration1to2 = Migration(1, 2, (database) async {
  await database.execute('ALTER TABLE WordStatus ADD COLUMN isBookmarked BOOLEAN default 0');
});