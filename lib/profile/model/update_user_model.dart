import 'package:sanitary_mart/auth/model/user_model.dart';

class UpdateUserModel {
  String? uId;
  String? userName;
  String? email;
  String? phone;
  String? address;

  UpdateUserModel({
    required this.uId,
    this.userName,
    this.address,
    this.email,
    this.phone,
  });

  Map<String, dynamic> toJson() => {
        'uId': uId,
        'userName': userName,
        'email': email,
        'phone': phone,
        'address': address,
      };

  static UpdateUserModel fromUserModel(UserModel userModel) {
    return UpdateUserModel(
        uId: userModel.uId,
        userName: userModel.userName,
        phone: userModel.phone,
        email: userModel.email,
        address: userModel.address);
  }
}
