import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/auth/screen/login_screen.dart';
import 'package:sanitary_mart/auth/screen/otp_screen.dart';
import 'package:sanitary_mart/auth/service/auth_service.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/constant/constant.dart';
import 'package:sanitary_mart/core/log/logger.dart';
import 'package:sanitary_mart/dashboard/ui/dashboard_screen.dart';
import 'package:sanitary_mart/profile/model/update_user_model.dart';
import 'package:sanitary_mart/profile/service/user_firebase_service.dart';
import 'package:sanitary_mart/profile/ui/screen/update_user_detail_screen.dart';
import 'package:sanitary_mart/util/storage_helper.dart';

class AuthenticationProvider extends ChangeNotifier {
  bool isLoading = false;
  final StorageHelper storageHelper;
  final AuthService authService;
  int? resendToken;
  String? deviceToken;
  bool isError = false;
  UserModel? _userModel;

  AuthenticationProvider(
      {required this.authService, required this.storageHelper}) {
    //loadFirebaseToken();
  }

  Future phoneLogin(String phoneNumber, {bool resend = false}) async {
    try {
      showLoader();
      await FirebaseAuth.instance.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: (PhoneAuthCredential credential) {
            hideLoader();
          },
          verificationFailed: (FirebaseAuthException e) {
            Get.snackbar(AppText.verificationFailedAlert, e.message.toString());
            hideLoader();
          },
          codeSent: (String verificationId, int? resendToken) {
            this.resendToken = resendToken;
            hideLoader();
            if (!resend) {
              Get.to(OTPScreen(
                phoneNumber: phoneNumber,
                verificationId: verificationId,
              ));
            }
          },
          codeAutoRetrievalTimeout: (String verificationId) {
            hideLoader();
          },
          forceResendingToken: resend ? resendToken : null);
    } on FirebaseAuthException catch (e) {
      Get.snackbar(AppText.error, e.message.toString());
      hideLoader();
    }
  }

  void hideLoader() {
    isLoading = false;
    notifyListeners();
  }

  Future verifyOTP({
    required String otp,
    required String verificationId,
  }) async {
    try {
      showLoader();
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: otp);
      UserCredential cred =
          await FirebaseAuth.instance.signInWithCredential(credential);
      String? uid = cred.user?.uid;
      if (uid != null) {
        storageHelper.saveUserId(uid);
      }
      hideLoader();

      openDashboardScreen();
    } on FirebaseAuthException catch (e) {
      hideLoader();
      Get.snackbar(AppText.error, e.message.toString());
    }
  }

  void openDashboardScreen() {
    Get.offAll(()=>const DashboardScreen());
  }

  ///@Deprecated
  Future loadLoggedStatus() async {
    showLoader();
    String? uid = await storageHelper.getUserId();
    hideLoader();
  }

  void showLoader() {
    isLoading = true;
    notifyListeners();
  }

  Future logout() async {
    await storageHelper.clearUserId();
    Get.off(LoginScreen());
  }

  Future signInWithGoogle() async {
    try {
      isError = false;
      showLoader();
      User? user = await authService.signInWithGoogle();
      if (user != null) {
        await saveUserDetail(user);
        FirebaseAnalytics.instance.setUserId(id: _userModel?.uId);
        UserFirebaseService firebaseAuthService = Get.find();
        UserModel? alreadyUser = await firebaseAuthService.getLoggedUser();
        if (alreadyUser != null &&
            (alreadyUser.phone?.isNotEmpty ?? false) &&
            (alreadyUser.address?.isNotEmpty ?? false)) {
          openDashboardScreen();
        } else {
          if (alreadyUser != null) {
            openUserDetailScreen(alreadyUser);
          }
        }
      }
    } catch (e) {
      isError = true;
      notifyListeners();
      AppUtil.showToast(e.toString(),isError: true);
    } finally {
      hideLoader();
    }
  }

  Future openUserDetailScreen(UserModel userModel) async {
    bool success = await Get.off(UpdateUserDetailsScreen(
      updateUserModel: UpdateUserModel.fromUserModel(userModel),
    ));
    if (success) {
      openDashboardScreen();
    }
  }

  Future<void> saveUserDetail(
    User user,
  ) async {
    isError = false;
    UserFirebaseService firebaseAuthService = Get.find();
    String? token = await firebaseAuthService.getFirebaseToken();
    UserModel userModel = UserModel(
      uId: user.uid,
      userName: user.displayName.toString(),
      email: user.email.toString(),
      phone: user.phoneNumber,
      userDeviceToken: token ?? '',
      isAdmin: false,
      isActive: true,
      createdOn: DateTime.now(),
    );
    await firebaseAuthService.saveUserDetails(userModel);
  }

  Future googleSignOut() async {
    try {
      showLoader();
      isError = false;
      await authService.googleSignOut();
      FirebaseAnalytics.instance.logEvent(name: 'logout');
      _userModel = null;
    } catch (e) {
      isError = true;
      notifyListeners();
      AppUtil.showToast(e.toString(),isError: true);
      FirebaseAnalytics.instance
          .logEvent(name: 'logout_error', parameters: {'error': e.toString()});
    } finally {
      hideLoader();
    }
  }

  Future loadFirebaseToken() async {
    try {
      isError = false;
      UserFirebaseService authFirebaseService = Get.find();
      deviceToken = await authFirebaseService.getFirebaseToken();
      if (deviceToken != null) {
        authFirebaseService.updateFirebaseToken(token: deviceToken!);
      }
    } catch (e) {
      isError = true;
      Log.e(e);
    }
  }

  String? getCurrentUser() {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }
}
