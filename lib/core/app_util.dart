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

  static void showWarningToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.amberAccent,
      textColor: Colors.black,
    );
  }

  static void showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  static void showPositiveToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.white,
      textColor: Colors.green,
    );
  }

  static String generateOrderId() {
    DateTime now = DateTime.now();
    return '${now.microsecondsSinceEpoch}';
  }

  static String convertTimestampInDate(int timestamp) {
    var timestampInSeconds = timestamp ~/ 1000;

    var dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestampInSeconds * 1000);
    var formatter = DateFormat('dd MMMM yyyy');
    return formatter.format(dateTime);
  }
}