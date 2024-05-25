import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/profile/model/update_user_model.dart';

class UserFirebaseService {
  Future saveUserDetails(UserModel userModel) async {
    final map = userModel.toJson();
    map.removeWhere((key, value) => value == null);
    final docRef =
        FirebaseFirestore.instance.collection('users').doc(userModel.uId);
    DocumentSnapshot documentSnapshot = await docRef.get();
    if (documentSnapshot.exists) {
      docRef.update(
        map,
      );
    } else {
      await docRef.set(
        map,
      );
    }
  }

  Future updateUserDetail(UpdateUserModel userRequest) async {
    final map = userRequest.toJson();
    map.removeWhere((key, value) => value == null);
    final docRef =
    FirebaseFirestore.instance.collection('users').doc(userRequest.uId);
    DocumentSnapshot documentSnapshot = await docRef.get();
    if (documentSnapshot.exists) {
      docRef.update(
        map,
      );
    }
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
    return null;
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

  // Future updateUserDetail({String? phone, String? address}) async {
  //   User? user = FirebaseAuth.instance.currentUser;
  //   if (user != null) {
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(user.uid)
  //         .update({
  //       'phone': phone,
  //       'address': address,
  //     });
  //   }
  // }
}
