import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/log/logger.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/profile/model/point_info.dart';
import 'package:sanitary_mart/profile/model/update_user_model.dart';
import 'package:sanitary_mart/profile/service/user_firebase_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? userModel;

  ProviderState providerState = ProviderState.idle;

  double totalPoints = 0;
  List<IncentivePointInfo> incentivePointsHistory = [];

  UserProvider() {
    loadUserModel();
  }

  Future<UserModel?> getCurrentUser() async {
    if (userModel != null) {
      return userModel;
    }
    await loadUserModel();
    return userModel;
  }

  Future loadUserModel() async {
    try {
      providerState = ProviderState.loading;
      notifyListeners();
      UserFirebaseService userFirebaseService = Get.find();
      UserModel? user = await userFirebaseService.getLoggedUser();
      if (user == null) {
        throw 'User not found';
      } else {
        userModel = user;
      }
      providerState = ProviderState.idle;
    } catch (e) {
      providerState = ProviderState.error;
      Log.e(e);
    } finally {
      notifyListeners();
    }
  }

  Future updateUserDetail(UpdateUserModel updateUserRequest) async {
    try {
      providerState = ProviderState.loading;
      notifyListeners();
      UserFirebaseService userFirebaseService = Get.find();
      await userFirebaseService.updateUserDetail(updateUserRequest);
      providerState = ProviderState.idle;
      await loadUserModel();
      AppUtil.showPositiveToast('User details updated successfully');
    } catch (e) {
      AppUtil.showToast('Unable to update user details', isError: true);
      providerState = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    userModel = null;
    notifyListeners();
  }

  Future fetchTotalIncentivePoints() async {
    try {
      totalPoints = 0;
      providerState = ProviderState.loading;
      UserFirebaseService userFirebaseService = Get.find();
      UserModel? userModel = await getCurrentUser();
      if (userModel != null) {
        totalPoints =
            await userFirebaseService.getIncentivePoints(userModel.uId);
        notifyListeners();
      }
      providerState = ProviderState.idle;
    } catch (e) {
      providerState = ProviderState.error;
    }
  }

  Future requestPointRedeem(IncentivePointInfo incentivePoint) async {
    try {
      totalPoints = 0;
      providerState = ProviderState.loading;
      UserFirebaseService userFirebaseService = Get.find();
      UserModel? userModel = await getCurrentUser();
      if (userModel != null) {
        await userFirebaseService.requestPointRedeem(
            userModel.uId, incentivePoint);
        AppUtil.showToast(
            'You incentive points sent for redeem. You will receive once the admin will process them');
        clearTotalIncentivePoints(userModel.uId);
        notifyListeners();
      }
      providerState = ProviderState.idle;
    } catch (e) {
      AppUtil.showErrorToast('Something went wrong');
      providerState = ProviderState.error;
    }
  }

  Future clearTotalIncentivePoints(String uId) async {
    UserFirebaseService userFirebaseService = Get.find();
    await userFirebaseService.clearTotalIncentivePoints(uId);
  }

  Future fetchIncentivePointsHistory() async {
    try {
      providerState = ProviderState.loading;
      UserFirebaseService userFirebaseService = Get.find();
      UserModel? userModel = await getCurrentUser();
      if (userModel != null) {
        incentivePointsHistory = await userFirebaseService.getIncentivePointsHistory(
            userModel.uId);
        notifyListeners();
      }
      providerState = ProviderState.idle;
    } catch (e) {
      AppUtil.showErrorToast('Something went wrong');
      providerState = ProviderState.error;
    }
  }
}
