import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:indonesia_flash_card/utils/analytics/analytics_event_entity.dart';

import 'analytics_parameters.dart';

class FirebaseAnalyticsUtils {
  static final analytics = FirebaseAnalytics.instance;

  static void login(String userId, String email) {
    FirebaseAnalyticsUtils.analytics.logLogin();
    FirebaseAnalyticsUtils.analytics.setUserId(id: userId);
    FirebaseAnalyticsUtils.analytics.setUserProperty(
        name: "Email", value: email);
  }

  static void screenTrack(AnalyticsScreen screen) {
    FirebaseAnalyticsUtils.analytics.setCurrentScreen(screenName: screen.name);
  }

  static void eventsTrack(AnalyticsEventEntity event) {
    FirebaseAnalyticsUtils.analytics.logEvent(
        name: event.name ?? '',
        parameters: event.analyticsEventDetail?.toJson()
    );
  }
}