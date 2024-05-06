import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/core/log/logger.dart';
import 'package:sanitary_mart/profile/service/user_firebase_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? userModel;

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
      UserFirebaseService userFirebaseService = Get.find();
      UserModel? user = await userFirebaseService.getLoggedUser();
      if(user == null){
        throw 'User not found';
      }else{
        userModel = user;
      }
      notifyListeners();
    } catch (e) {
      Log.e(e);
    }
  }

  void reset() {
    userModel = null;
    notifyListeners();
  }
}
