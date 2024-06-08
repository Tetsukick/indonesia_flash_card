// Package imports:
import 'package:floor/floor.dart';

@entity
class WordStatus {

  WordStatus({
    this.id,
    required this.wordId,
    required this.status,
    this.isBookmarked = false,
  });
  @PrimaryKey(autoGenerate: true)
  int? id;
  final int wordId;
  int status;
  bool isBookmarked;
}
