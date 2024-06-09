// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:floor/floor.dart';

// Project imports:
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';
import 'package:indonesia_flash_card/generated/json/tango_entity.g.dart';

@JsonSerializable()
@entity
class TangoEntity {

  TangoEntity({
		this.id,
		this.indonesian,
		this.japanese,
		this.english,
		this.description,
		this.example,
		this.exampleJp,
		this.level,
		this.partOfSpeech,
		this.category,
		this.frequency,
		this.rankFrequency,
	});

  factory TangoEntity.fromJson(Map<String, dynamic> json) => $TangoEntityFromJson(json);

	@PrimaryKey()
	int? id;
	String? indonesian;
	String? japanese;
	String? english;
	String? description;
	String? example;
	@JSONField(name: 'example_jp')
	String? exampleJp;
	int? level;
	@JSONField(name: 'part_of_speech')
	int? partOfSpeech;
	int? category;
	int? frequency;
	int? rankFrequency;

  Map<String, dynamic> toJson() => $TangoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
