// Package imports:
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

// Project imports:
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
        timestamp = Timestamp(data['_seconds']!, data['_nanoseconds']!);
      } catch (e) {
        logger.d(e);
      }
    }
    return timestamp?.toDate() ?? DateTime.now();
  }

  @override
  dynamic toJson(DateTime? dateTime) {
    final timestamp = dateTime == null ? FieldValue.serverTimestamp() : Timestamp.fromDate(dateTime);
    return timestamp;
  }
}
