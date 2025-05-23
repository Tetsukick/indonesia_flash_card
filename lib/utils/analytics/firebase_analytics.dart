// Dart imports:
import 'dart:io';

// Package imports:
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

// Project imports:
import 'package:indonesia_flash_card/utils/analytics/analytics_event_entity.dart';
import 'analytics_parameters.dart';

class FirebaseAnalyticsUtils {
  static final analytics = FirebaseAnalytics.instance;

  static void login(String userId, String email) {
    if (FirebaseAnalyticsUtils._canTrack()) {
      FirebaseAnalyticsUtils.analytics.logLogin();
      FirebaseAnalyticsUtils.analytics.setUserId(id: userId);
      FirebaseAnalyticsUtils.analytics.setUserProperty(
          name: 'Email', value: email,);
    }
  }

  static void screenTrack(AnalyticsScreen screen) {
    if (FirebaseAnalyticsUtils._canTrack()) {
      FirebaseAnalyticsUtils.analytics.logScreenView(screenName: screen.name);
    }
  }

  static void eventsTrack(AnalyticsEventEntity event) {
    if (FirebaseAnalyticsUtils._canTrack()) {
      FirebaseAnalyticsUtils.analytics.logEvent(
          name: event.name ?? '',
          // parameters: event.analyticsEventDetail?.toJson() as Map<String, Object>,
      );
    }
  }

  static bool _canTrack() {
    return true;
    if (Platform.isIOS) {
      return AppTrackingTransparency.trackingAuthorizationStatus == TrackingStatus.authorized;
    } else {
      return true;
    }
  }
}
