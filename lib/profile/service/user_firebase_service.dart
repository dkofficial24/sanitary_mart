import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/profile/model/point_info.dart';
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

  Future updateIncentivePoints(String uId, double incentivePoints) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .get();
    num points = 0.0;
    if (snapshot.exists) {
      final map = snapshot.data();
      if (map != null) {
        final iPoints = map['points'];
        points = iPoints;
      }
    }
    points += incentivePoints;

    await FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .set({'points': points});
  }

  Future clearTotalIncentivePoints(String uId) async {
    await FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .set({'points': 0.0});
  }

  Future<double> getIncentivePoints(String uId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .get();
    if (snapshot.exists) {
      final map = snapshot.data();
      if (map != null) {
        return map['points'];
      }
    }
    return 0.0;
  }

  Future requestPointRedeem(
      String uId, IncentivePointInfo incentivePoint) async {
    final docRef = FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .collection('data')
        .doc();
    incentivePoint.id = docRef.id;
    await docRef.set(incentivePoint.toDocument());
  }

  // Get list of IncentivePointInfo
  Future<List<IncentivePointInfo>> getIncentivePointsHistory(String uId) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('incentive_points')
        .doc(uId)
        .collection('data')
        .orderBy('updated', descending: true)
        .get();
    return querySnapshot.docs
        .map((doc) => IncentivePointInfo.fromDocument(doc))
        .toList();
  }
}
