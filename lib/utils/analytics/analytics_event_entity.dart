// Dart imports:
import 'dart:convert';

// Project imports:
import 'package:indonesia_flash_card/generated/json/analytics_event_entity.g.dart';
import 'package:indonesia_flash_card/generated/json/base/json_field.dart';

@JsonSerializable()
class AnalyticsEventEntity {
  
  AnalyticsEventEntity();

  factory AnalyticsEventEntity.fromJson(Map<String, dynamic> json) => $AnalyticsEventEntityFromJson(json);

	String? name;
	@JSONField(name: 'analytics_event_detail')
	AnalyticsEventAnalyticsEventDetail? analyticsEventDetail;

  Map<String, dynamic> toJson() => $AnalyticsEventEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class AnalyticsEventAnalyticsEventDetail {
  
  AnalyticsEventAnalyticsEventDetail();

  factory AnalyticsEventAnalyticsEventDetail.fromJson(Map<String, dynamic> json) => $AnalyticsEventAnalyticsEventDetailFromJson(json);

	String? id;
	String? screen;
	String? action;
	String? item;
	String? others;

  Map<String, dynamic> toJson() => $AnalyticsEventAnalyticsEventDetailToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
