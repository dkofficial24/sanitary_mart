import 'package:flutter/foundation.dart';

class Log {
  static void i(dynamic msg) {
    if (kDebugMode) {
      print('Vendor INFO: $msg');
    }
  }

  static void d(dynamic msg) {
    if (kDebugMode) {
      print('Vendor DEBUG: $msg');
    }
  }

  static void e(dynamic msg) {
    if (kDebugMode) {
      print('Vendor ERROR: $msg');
    }
  }
}
