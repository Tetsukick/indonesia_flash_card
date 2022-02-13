import 'package:indonesia_flash_card/generated/json/base/json_convert_content.dart';
import 'package:indonesia_flash_card/model/tango_entity.dart';

TangoEntity $TangoEntityFromJson(Map<String, dynamic> json) {
	final TangoEntity tangoEntity = TangoEntity();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		tangoEntity.id = id;
	}
	final String? indonesian = jsonConvert.convert<String>(json['indonesian']);
	if (indonesian != null) {
		tangoEntity.indonesian = indonesian;
	}
	final String? japanese = jsonConvert.convert<String>(json['japanese']);
	if (japanese != null) {
		tangoEntity.japanese = japanese;
	}
	final String? english = jsonConvert.convert<String>(json['english']);
	if (english != null) {
		tangoEntity.english = english;
	}
	final String? description = jsonConvert.convert<String>(json['description']);
	if (description != null) {
		tangoEntity.description = description;
	}
	final String? example = jsonConvert.convert<String>(json['example']);
	if (example != null) {
		tangoEntity.example = example;
	}
	final String? exampleJp = jsonConvert.convert<String>(json['example_jp']);
	if (exampleJp != null) {
		tangoEntity.exampleJp = exampleJp;
	}
	final int? level = jsonConvert.convert<int>(json['level']);
	if (level != null) {
		tangoEntity.level = level;
	}
	final int? partOfSpeech = jsonConvert.convert<int>(json['part_of_speech']);
	if (partOfSpeech != null) {
		tangoEntity.partOfSpeech = partOfSpeech;
	}
	final int? category = jsonConvert.convert<int>(json['category']);
	if (category != null) {
		tangoEntity.category = category;
	}
	return tangoEntity;
}

Map<String, dynamic> $TangoEntityToJson(TangoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['indonesian'] = entity.indonesian;
	data['japanese'] = entity.japanese;
	data['english'] = entity.english;
	data['description'] = entity.description;
	data['example'] = entity.example;
	data['example_jp'] = entity.exampleJp;
	data['level'] = entity.level;
	data['part_of_speech'] = entity.partOfSpeech;
	data['category'] = entity.category;
	return data;
}