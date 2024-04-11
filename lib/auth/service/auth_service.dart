import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sanitary_mart/auth/model/user_model.dart';
import 'package:sanitary_mart/profile/service/user_firebase_service.dart';

class AuthService {

  Future<UserModel?> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);
    final User? user = userCredential.user;
    if (user != null) {
      UserFirebaseService firebaseAuthService = Get.find();
      String? token = await firebaseAuthService.getFirebaseToken();
      UserModel userModel = UserModel(
        uId: user.uid,
        userName: user.displayName.toString(),
        email: user.email.toString(),
        phone: user.phoneNumber.toString(),
        userDeviceToken: token ?? '',
        isAdmin: false,
        isActive: true,
        createdOn: DateTime.now(),
      );
      await firebaseAuthService.saveUser(userModel);
      return userModel;
    }
  }

  Future googleSignOut()async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    googleSignIn.signOut();
  }

}
