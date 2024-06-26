// Package imports:
import 'package:floor/floor.dart';

@entity
class Activity {

  Activity({
    this.id,
    required this.wordId,
    required this.date,
  });
  @PrimaryKey(autoGenerate: true)
  int? id;
  final int wordId;
  final String date;
}
