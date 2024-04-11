class UserModel {
   String uId;
  String userName;
  String email;
  String phone;
  String userDeviceToken;
  bool isAdmin;
  bool isActive;
  DateTime createdOn;
  bool? verified;

  UserModel(
      {required this.uId,
      required this.userName,
      required this.email,
      required this.phone,
      required this.userDeviceToken,
      required this.isAdmin,
      required this.isActive,
      required this.createdOn,
      this.verified = false});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uId: json['uId'] as String,
        userName: json['userName'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        userDeviceToken: json['userDeviceToken'] as String,
        isAdmin: json['isAdmin'] as bool,
        isActive: json['isActive'] as bool,
        verified: json['verified'] as bool?,
        createdOn: DateTime.parse(json['createdOn'] as String),
      );

  Map<String, dynamic> toJson() => {
    'uId': uId,
    'userName': userName,
    'email': email,
    'phone': phone,
    'userDeviceToken': userDeviceToken,
    'isAdmin': isAdmin,
    'isActive': isActive,
    'createdOn': createdOn.toIso8601String(),
  };

  Map<String, dynamic> toOrderJson() => {
    'uId': uId,
    'userName': userName,
    'email': email,
    'phone': phone,
    'userDeviceToken': userDeviceToken,
  };

  factory UserModel.fromOrderJson(Map<String, dynamic> json) => UserModel(
    uId: json['uId'] as String,
    userName: json['userName'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String,
    userDeviceToken: json['userDeviceToken'] as String,
    isActive: json['isActive'] as bool,
    createdOn: DateTime.parse(json['createdOn'] as String), isAdmin: false,
  );
  
}
