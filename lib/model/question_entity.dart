import 'dart:convert';
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';
import 'package:indonesia_flash_card/generated/json/question_entity.g.dart';

@JsonSerializable()
class QuestionEntity {

	String? question;
	@JSONField(name: "user_token")
	String? userToken;
	@JSONField(name: "creted_at")
	int? cretedAt;
	List<String>? categories;
  
  QuestionEntity();

  factory QuestionEntity.fromJson(Map<String, dynamic> json) => $QuestionEntityFromJson(json);

  Map<String, dynamic> toJson() => $QuestionEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}