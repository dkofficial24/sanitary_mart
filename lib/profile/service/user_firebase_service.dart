import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';

class UserFirebaseService {
  Future saveUser(UserModel userModel) async {
    await FirebaseFirestore.instance.collection('users').doc(userModel.uId).set(
          userModel.toJson(),
        );
  }

  Future<UserModel?> getLoggedUser() async {
    String? uId = FirebaseAuth.instance.currentUser?.uid;
    if (uId != null) {
      DocumentSnapshot documentSnapshot =
          await FirebaseFirestore.instance.collection('users').doc(uId).get();
      if (documentSnapshot.exists) {
        return UserModel.fromJson(
            documentSnapshot.data() as Map<String, dynamic>);
      }
    }
    throw 'User not found';
  }

  Future<String?> getFirebaseToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  Future updateFirebaseToken({
    required String token,
  }) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'userDeviceToken': token});
    }
  }
}
