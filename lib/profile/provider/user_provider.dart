import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/core/app_util.dart';
import 'package:sanitary_mart/core/log/logger.dart';
import 'package:sanitary_mart/core/provider_state.dart';
import 'package:sanitary_mart/profile/model/update_user_model.dart';
import 'package:sanitary_mart/profile/service/user_firebase_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? userModel;

  ProviderState providerState = ProviderState.idle;

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
      AppUtil.showToast('Unable to update user details',isError: true);
      providerState = ProviderState.error;
    } finally {
      notifyListeners();
    }
  }

  void reset() {
    userModel = null;
    notifyListeners();
  }
}
