import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:echat/Components/CustomToast/CustomToast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthentication {
  //Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult.first == ConnectivityResult.none) {
        Fluttertoast.showToast(msg: "No internet connection");
        throw FirebaseAuthException(
          code: 'no-internet',
          message: 'No internet connection. Please check your network.',
        );
      }
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      return userCredential;
    } catch (err) {
      Fluttertoast.showToast(msg: "google-sign-in-failed");
      throw FirebaseAuthException(
        code: 'google-sign-in-failed',
        message: 'Google sign-in failed: $err',
      );
    }
  }
  //Sign Out
  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      Navigator.pushNamedAndRemoveUntil(context, "/gmailAuth", (route) => false,);
      showSuccessToast("Successfully Sign Out ");
    } catch (err) {
      showErrorToast("Error Occurred in Sign out");
      throw FirebaseAuthException(
        code: 'Sign out Error',
        message: 'Error Occurred in Sign out',
      );
    }
  }
}
