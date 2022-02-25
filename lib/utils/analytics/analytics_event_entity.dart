import 'dart:convert';
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';
import 'package:indonesia_flash_card/generated/json/analytics_event_entity.g.dart';

@JsonSerializable()
class AnalyticsEventEntity {

	String? name;
	@JSONField(name: "analytics_event_detail")
	AnalyticsEventAnalyticsEventDetail? analyticsEventDetail;
  
  AnalyticsEventEntity();

  factory AnalyticsEventEntity.fromJson(Map<String, dynamic> json) => $AnalyticsEventEntityFromJson(json);

  Map<String, dynamic> toJson() => $AnalyticsEventEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class AnalyticsEventAnalyticsEventDetail {

	String? id;
	String? screen;
	String? action;
	String? item;
	String? others;
  
  AnalyticsEventAnalyticsEventDetail();

  factory AnalyticsEventAnalyticsEventDetail.fromJson(Map<String, dynamic> json) => $AnalyticsEventAnalyticsEventDetailFromJson(json);

  Map<String, dynamic> toJson() => $AnalyticsEventAnalyticsEventDetailToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}