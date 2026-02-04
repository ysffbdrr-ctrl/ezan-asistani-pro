import 'package:flutter/foundation.dart';

/// Production-safe logger
/// Sadece debug modda log yazdırır, release'de hiçbir şey yapmaz
class AppLogger {
  static void log(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('$prefix$message');
    }
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      debugPrint('❌ ERROR: $message');
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }

  static void warning(String message, {Object? error}) {
    if (kDebugMode) {
      debugPrint('⚠️ WARNING: $message');
      if (error != null) {
        debugPrint('Warning details: $error');
      }
    }
  }

  static void info(String message, {String? tag}) {
    if (kDebugMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      debugPrint('ℹ️ $prefix$message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      debugPrint('✅ $message');
    }
  }
}
