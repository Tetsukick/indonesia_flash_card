// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';
import 'package:indonesia_flash_card/generated/json/question_answer_entity.g.dart';

@JsonSerializable()
class QuestionAnswerEntity {
  
  QuestionAnswerEntity();

  factory QuestionAnswerEntity.fromJson(Map<String, dynamic> json) => $QuestionAnswerEntityFromJson(json);

  String? id;
	String? answer;
	@JSONField(name: 'is_best')
	bool? isBest;
	@JSONField(name: 'user_token')
	String? userToken;
	@JSONField(name: 'created_at')
	DateTime? createdAt;

  Map<String, dynamic> toJson() => $QuestionAnswerEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
