import 'package:indonesia_flash_card/generated/json/base/json_convert_content.dart';
import 'package:indonesia_flash_card/model/question_entity.dart';

QuestionEntity $QuestionEntityFromJson(Map<String, dynamic> json) {
	final QuestionEntity questionEntity = QuestionEntity();
	final String? question = jsonConvert.convert<String>(json['question']);
	if (question != null) {
		questionEntity.question = question;
	}
	final String? userToken = jsonConvert.convert<String>(json['user_token']);
	if (userToken != null) {
		questionEntity.userToken = userToken;
	}
	final int? cretedAt = jsonConvert.convert<int>(json['creted_at']);
	if (cretedAt != null) {
		questionEntity.cretedAt = cretedAt;
	}
	final List<String>? categories = jsonConvert.convertListNotNull<String>(json['categories']);
	if (categories != null) {
		questionEntity.categories = categories;
	}
	return questionEntity;
}

Map<String, dynamic> $QuestionEntityToJson(QuestionEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['question'] = entity.question;
	data['user_token'] = entity.userToken;
	data['creted_at'] = entity.cretedAt;
	data['categories'] =  entity.categories;
	return data;
}