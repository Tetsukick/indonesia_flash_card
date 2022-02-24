import 'package:floor/floor.dart';

@entity
class WordStatus {
  @PrimaryKey(autoGenerate: true)
  int? id;
  final int wordId;
  int status;
  bool isBookmarked;

  WordStatus({
    this.id,
    required this.wordId,
    required this.status,
    this.isBookmarked = false,
  });
}