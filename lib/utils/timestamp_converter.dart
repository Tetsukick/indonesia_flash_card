import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

import 'logger.dart';

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic data) {
    Timestamp? timestamp;
    if (data is Timestamp) {
      timestamp = data;
    } else if (data is Map<String, int>) {
      try {
        timestamp = Timestamp(data['_seconds'] as int, data['_nanoseconds'] as int);
      } catch (e) {
        logger.d(e);
      }
    }
    return timestamp?.toDate() ?? DateTime.now();
  }

  @override
  Map<String, dynamic> toJson(DateTime? dateTime) {
    final timestamp = dateTime == null ? Timestamp.now() : Timestamp.fromDate(dateTime);
    return {
      '_seconds': timestamp.seconds,
      '_nanoseconds': timestamp.nanoseconds,
    };
  }
}