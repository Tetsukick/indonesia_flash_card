import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final crashReporter = Provider<ICrashReporter>((ref) => CrashReporter.instance);

abstract class ICrashReporter {
  Future<void> initialize();
  Future<void> setIdentify(String id);
  Future<void> report(dynamic exception, StackTrace? stack);
}

class CrashReporter implements ICrashReporter {
  CrashReporter._(this._reporter);
  final FirebaseCrashlytics _reporter;

  static ICrashReporter? _instance;
  static ICrashReporter get instance {
    _instance ??= CrashReporter._(FirebaseCrashlytics.instance);

    return _instance!;
  }

  @override
  Future<void> initialize() async {
    await _reporter.setCrashlyticsCollectionEnabled(true);
  }

  @override
  Future<void> setIdentify(String id) async {
    await _reporter.setUserIdentifier(id);
  }

  @override
  Future<void> report(dynamic exception, StackTrace? stack) async {
    await _reporter.recordError(exception, stack);
  }
}