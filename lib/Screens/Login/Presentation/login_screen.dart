import 'package:echat/Components/CommonFunctions.dart';
import 'package:echat/Components/CustomToast/CustomToast.dart';
import 'package:echat/Screens/ChatList/Presentation/chat_list.dart';
import 'package:echat/Utils/Constants/TextConstants.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Firebase/controllers/firebase_auth.dart';
import '../../../Firebase/controllers/firebase_firestore.dart';
import '../../../Models/UserModel.dart';
import '../../../Utils/Constants/ImageConstants.dart';

class GmailAuthPage extends StatefulWidget {
  @override
  _GmailAuthPageState createState() => _GmailAuthPageState();
}

class _GmailAuthPageState extends State<GmailAuthPage> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(ImageConstants.googleLogo, height: 80.h),
            SizedBox(height: 20.h),
            Text(
              TextConstants.signINGmail,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _isSigningIn
                ? CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: loginFunction,
                    icon: Image.asset(ImageConstants.googleLogo, height: 24),
                    label: Text(TextConstants.signINGmail),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }

  Future<void> loginFunction() async {
    final SharedPreferences localDb = await SharedPreferences.getInstance();
    setState(() {
      _isSigningIn = true;
    });
    UserCredential? user = await FirebaseAuthentication().signInWithGoogle();

    await FirebaseFireStore().insertUser(UserModel(
        name: user!.user!.displayName!,
        email: user.user!.email!,
        imageUrl: user.user!.photoURL!,
        createdAt: DateTime.now(),
        role: "user",
        firebaseUid: user.user!.uid!,
        lastSignInTime: DateTime.now()),user.user!.uid);
    showSuccessToast(
        "${capitalizeFirstLetter(user!.user!.displayName!)} is Successfully Login");
    setState(() {
      _isSigningIn = false;
    });
    localDb.setString(
      "username",
      user.user!.displayName!,
    );
    localDb.setString(
      "uuid",
      user.user!.uid,
    );
    await Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => ChatList()),
      (Route<dynamic> route) => false,
    );
  }
}
