import 'dart:math';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class AppUtil {
  static void showToast(String message, {bool isError = false}) {
    Color? bgColor;
    Color? textColor;

    if (isError) {
      bgColor = Colors.red;
      textColor = Colors.white;
    }

    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      backgroundColor: bgColor,
      textColor: textColor,
    );
  }

  static String generateOrderId() {
    DateTime now = DateTime.now();
    int randomNumber = Random().nextInt(99999);
    return '${now.microsecondsSinceEpoch}_$randomNumber';
  }

  static String convertTimestampInDate(int timestamp) {
    var timestampInSeconds = timestamp ~/ 1000;

    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestampInSeconds * 1000);
    var formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(dateTime);
  }
}