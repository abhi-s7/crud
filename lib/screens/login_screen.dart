import 'package:crud/db/db.dart';
import 'package:crud/screens/home_screen.dart';
import 'package:crud/screens/verify_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  DbOperation dbOperation = new DbOperation();
  final phoneNumberEditingController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  _authenticateUsingPhone() async {
    String phoneNumberStr = '+91' + phoneNumberEditingController.text;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumberStr,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Sign the user in (or link) with the auto-generated credential
        await auth.signInWithCredential(credential).then((value) {
          print('Login Successfull: ${value.user.uid}');
          Navigator.pushReplacementNamed(context, HomeScreen.id);
        }).catchError((onError) => print('Error: $onError'));
      },
      verificationFailed: (FirebaseAuthException e) {
        if (e.code == 'invalid-phone-number') {
          print('The provided phone number is not valid.');
        } else {
          print('Error: ${e.code}');
        }
      },
      codeSent: (String verificationId, int resendToken) async {
        // Update the UI - wait for the user to enter the SMS code
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => VerifyScreen(
                      verificationId: verificationId,
                    )));
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3edf7),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue with Phone',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 50,
                ),
                TextField(
                  controller: phoneNumberEditingController,
                  maxLength: 10,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter mobile number',
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(color: Color(0xff694fa0)),
                    floatingLabelStyle: TextStyle(color: Color(0xff694fa0)),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 60,
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Material(
                color: Color(0xff694fa0),
                borderRadius: BorderRadius.all(Radius.circular(30.0)),
                elevation: 5.0,
                child: MaterialButton(
                  onPressed: () {
                    // login functionality.
                    _authenticateUsingPhone();
                  },
                  minWidth: 140.0,
                  height: 32.0,
                  child: Text(
                    'CONTINUE',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
