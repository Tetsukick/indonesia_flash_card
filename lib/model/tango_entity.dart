import 'dart:convert';
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';
import 'package:indonesia_flash_card/generated/json/tango_entity.g.dart';

@JsonSerializable()
class TangoEntity {

	int? id;
	String? indonesian;
	String? japanese;
	String? english;
	String? description;
	String? example;
	@JSONField(name: "example_jp")
	String? exampleJp;
	int? level;
	@JSONField(name: "part_of_speech")
	int? partOfSpeech;
	int? category;
	int? frequency;
	int? rankFrequency;
  
  TangoEntity();

  factory TangoEntity.fromJson(Map<String, dynamic> json) => $TangoEntityFromJson(json);

  Map<String, dynamic> toJson() => $TangoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}