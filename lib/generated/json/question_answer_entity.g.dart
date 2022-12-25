import 'package:indonesia_flash_card/generated/json/base/json_convert_content.dart';
import 'package:indonesia_flash_card/model/question_answer_entity.dart';

QuestionAnswerEntity $QuestionAnswerEntityFromJson(Map<String, dynamic> json) {
	final QuestionAnswerEntity questionAnswerEntity = QuestionAnswerEntity();
	final String? answer = jsonConvert.convert<String>(json['answer']);
	if (answer != null) {
		questionAnswerEntity.answer = answer;
	}
	final bool? isBest = jsonConvert.convert<bool>(json['is_best']);
	if (isBest != null) {
		questionAnswerEntity.isBest = isBest;
	}
	final String? userToken = jsonConvert.convert<String>(json['user_token']);
	if (userToken != null) {
		questionAnswerEntity.userToken = userToken;
	}
	final int? createdAt = jsonConvert.convert<int>(json['created_at']);
	if (createdAt != null) {
		questionAnswerEntity.createdAt = createdAt;
	}
	return questionAnswerEntity;
}

Map<String, dynamic> $QuestionAnswerEntityToJson(QuestionAnswerEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['answer'] = entity.answer;
	data['is_best'] = entity.isBest;
	data['user_token'] = entity.userToken;
	data['created_at'] = entity.createdAt;
	return data;
}