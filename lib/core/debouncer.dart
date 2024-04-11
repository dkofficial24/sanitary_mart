import 'dart:async';

import 'package:flutter/cupertino.dart';

class DeBouncer {
  int? milliseconds;
  VoidCallback? action;

  static Timer? timer;

  static run(VoidCallback action, {int milliseconds = 300}) {
    if (null != timer) {
      timer!.cancel();
    }
    timer = Timer(
      Duration(milliseconds: milliseconds),
      action,
    );
  }
}
