// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';
import 'package:indonesia_flash_card/generated/json/translate_response_entity.g.dart';

@JsonSerializable()
class TranslateResponseEntity {
  
  TranslateResponseEntity();

  factory TranslateResponseEntity.fromJson(Map<String, dynamic> json) => $TranslateResponseEntityFromJson(json);

	int? code;
	String? text;

  Map<String, dynamic> toJson() => $TranslateResponseEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
