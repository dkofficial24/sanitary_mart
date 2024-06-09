import 'package:sanitary_mart/core/constant/app_const.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  Future saveUserId(String userId) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('UserIdKey', userId);
  }

  Future<String?> getUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('UserIdKey');
  }

  Future clearUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.remove('UserIdKey');
  }

  Future saveViewType(bool isGrid) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('ViewTypeKey', isGrid);
  }

  Future<bool> isGridViewType() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getBool('ViewTypeKey') ?? AppConst.isGridDefaultView;
  }
}
