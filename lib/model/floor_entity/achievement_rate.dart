
import 'package:floor/floor.dart';

@entity
class AchievementRate {
  AchievementRate({
    required this.id,
    required this.rate,
    required this.updatedAt,
  });

  @primaryKey
  final String id;
  final double rate;
  final int updatedAt;
}
