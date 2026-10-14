import 'package:flutter/foundation.dart';

class AppLog {
  static void i(String tag, String message) {
    if (kDebugMode) {
      print('ℹ️ [$tag]: $message');
    }
  }

  static void w(String tag, String message) {
    if (kDebugMode) {
      print('⚠️ [$tag]: $message');
    }
  }

  static void e(String tag, Object error, [StackTrace? stackTrace]) {
    debugPrint('❌ [$tag] Error: $error');
    if (stackTrace != null && kDebugMode) {
      debugPrint(stackTrace.toString());
    }
  }
}
