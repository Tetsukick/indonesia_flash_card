import 'package:floor/floor.dart';

final migration2to3 = Migration(2, 3, (database) async {
  await database.execute('CREATE TABLE TangoEntity(id INTEGER PRIMARY KEY, indonesian TEXT, japanese TEXT, english TEXT, description TEXT, example TEXT, exampleJp TEXT, level INTEGER, partOfSpeech INTEGER, category INTEGER, frequency INTEGER, rankFrequency INTEGER)');
});