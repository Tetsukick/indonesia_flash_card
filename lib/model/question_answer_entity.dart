import 'dart:convert';
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';
import 'package:indonesia_flash_card/generated/json/question_answer_entity.g.dart';

@JsonSerializable()
class QuestionAnswerEntity {

	String? answer;
	@JSONField(name: "is_best")
	bool? isBest;
	@JSONField(name: "user_token")
	String? userToken;
	@JSONField(name: "created_at")
	int? createdAt;
  
  QuestionAnswerEntity();

  factory QuestionAnswerEntity.fromJson(Map<String, dynamic> json) => $QuestionAnswerEntityFromJson(json);

  Map<String, dynamic> toJson() => $QuestionAnswerEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}