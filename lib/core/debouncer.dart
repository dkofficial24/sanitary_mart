import 'dart:async';

import 'package:flutter/cupertino.dart';

class DeBouncer {
  int? milliseconds;
  VoidCallback? action;

  static Timer? timer;

  static run(VoidCallback action) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      const Duration(milliseconds: Duration.millisecondsPerSecond),
      action,
    );
  }
}
