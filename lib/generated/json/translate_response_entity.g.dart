import 'package:indonesia_flash_card/generated/json/base/json_convert_content.dart';
import 'package:indonesia_flash_card/model/translate_response_entity.dart';

TranslateResponseEntity $TranslateResponseEntityFromJson(Map<String, dynamic> json) {
	final TranslateResponseEntity translateResponseEntity = TranslateResponseEntity();
	final int? code = jsonConvert.convert<int>(json['code']);
	if (code != null) {
		translateResponseEntity.code = code;
	}
	final String? text = jsonConvert.convert<String>(json['text']);
	if (text != null) {
		translateResponseEntity.text = text;
	}
	return translateResponseEntity;
}

Map<String, dynamic> $TranslateResponseEntityToJson(TranslateResponseEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['code'] = entity.code;
	data['text'] = entity.text;
	return data;
}