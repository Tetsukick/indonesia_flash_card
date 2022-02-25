import 'package:indonesia_flash_card/generated/json/base/json_convert_content.dart';
import 'package:indonesia_flash_card/utils/analytics/analytics_event_entity.dart';

AnalyticsEventEntity $AnalyticsEventEntityFromJson(Map<String, dynamic> json) {
	final AnalyticsEventEntity analyticsEventEntity = AnalyticsEventEntity();
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		analyticsEventEntity.name = name;
	}
	final AnalyticsEventAnalyticsEventDetail? analyticsEventDetail = jsonConvert.convert<AnalyticsEventAnalyticsEventDetail>(json['analytics_event_detail']);
	if (analyticsEventDetail != null) {
		analyticsEventEntity.analyticsEventDetail = analyticsEventDetail;
	}
	return analyticsEventEntity;
}

Map<String, dynamic> $AnalyticsEventEntityToJson(AnalyticsEventEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['name'] = entity.name;
	data['analytics_event_detail'] = entity.analyticsEventDetail?.toJson();
	return data;
}

AnalyticsEventAnalyticsEventDetail $AnalyticsEventAnalyticsEventDetailFromJson(Map<String, dynamic> json) {
	final AnalyticsEventAnalyticsEventDetail analyticsEventAnalyticsEventDetail = AnalyticsEventAnalyticsEventDetail();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		analyticsEventAnalyticsEventDetail.id = id;
	}
	final String? screen = jsonConvert.convert<String>(json['screen']);
	if (screen != null) {
		analyticsEventAnalyticsEventDetail.screen = screen;
	}
	final String? action = jsonConvert.convert<String>(json['action']);
	if (action != null) {
		analyticsEventAnalyticsEventDetail.action = action;
	}
	final String? item = jsonConvert.convert<String>(json['item']);
	if (item != null) {
		analyticsEventAnalyticsEventDetail.item = item;
	}
	final String? others = jsonConvert.convert<String>(json['others']);
	if (others != null) {
		analyticsEventAnalyticsEventDetail.others = others;
	}
	return analyticsEventAnalyticsEventDetail;
}

Map<String, dynamic> $AnalyticsEventAnalyticsEventDetailToJson(AnalyticsEventAnalyticsEventDetail entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['screen'] = entity.screen;
	data['action'] = entity.action;
	data['item'] = entity.item;
	data['others'] = entity.others;
	return data;
}