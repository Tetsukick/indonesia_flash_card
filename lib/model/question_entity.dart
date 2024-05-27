import 'dart:convert';
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';
import 'package:indonesia_flash_card/generated/json/question_entity.g.dart';

@JsonSerializable()
class QuestionEntity {
  
  QuestionEntity();

  factory QuestionEntity.fromJson(Map<String, dynamic> json) => $QuestionEntityFromJson(json);

  String? id;
	String? question;
	@JSONField(name: 'user_token')
	String? userToken;
	@JSONField(name: 'created_at')
	DateTime? createdAt;
	List<String>? categories;

  Map<String, dynamic> toJson() => $QuestionEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}