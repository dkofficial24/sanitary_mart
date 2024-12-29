import 'package:firebase_core/firebase_core.dart';
import 'package:sanitary_mart/core/app_util.dart';

class ErrorUtil {
  // Common error handling function for FirebaseException
  static String handleFirebaseError(e) {
    String errorMessage;

    if (e is FirebaseException) {
      // Check for network-related errors
      if ((e.message?.contains("unavailable") ?? false)) {
        errorMessage =
        'Network unavailable. Your action will be completed once you are online.';
      } else {
        // Generic Firebase error message
        errorMessage = e.message ?? 'An error occurred. Please try again later.';
      }
    } else {
      // Handle other types of exceptions
      errorMessage = e.toString() ?? 'An unexpected error occurred. Please try again later.';
    }

    AppUtil.showToast(errorMessage, isError: true);
    return errorMessage;
  }
}
