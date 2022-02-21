import 'package:floor/floor.dart';

@entity
class Activity {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final int wordId;
  final String date;

  Activity({
    this.id,
    required this.wordId,
    required this.date
  });
}