import 'package:crud/db/db.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

import 'home_screen.dart';

class VerifyScreen extends StatelessWidget {
  static const String id = 'verify_screen';
  final verificationId;
  static String code;
  final DbOperation dbOperation = new DbOperation();

  VerifyScreen({this.verificationId});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    _authenicateWithOTP() async {
      print('Verification Id: $verificationId');
      print('Code: $code');
      FirebaseAuth auth = FirebaseAuth.instance;
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);

      // Sign the user in (or link) with the credential
      await auth.signInWithCredential(credential).then((value) {
        print('Singin completed $value');

        Navigator.of(context).pushNamedAndRemoveUntil(
            HomeScreen.id, (Route<dynamic> route) => false);
      }).catchError((error) {
        print('Error: ${error.toString()}');
        return null;
      });
    }

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
                  'Verify your phone',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(
                  height: 40,
                ),
                Text(
                  'Enter code',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xff694fa0),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                OtpTextField(
                  numberOfFields: 6,
                  fieldWidth: media.width / 8,
                  cursorColor: Color(0xff694fa0),
                  borderColor: Color(0xff694fa0),
                  mainAxisAlignment: MainAxisAlignment.start,
                  //set to true to show as box or false to show as dash
                  showFieldAsBox: true,
                  //runs when a code is typed in
                  onCodeChanged: (String code) {
                    //handle validation or checks here
                  },
                  //runs when every textfield is filled
                  onSubmit: (String verificationCode) {
                    code = verificationCode;
                    print('Code is $code');
                  }, // end onSubmit
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
                  onPressed: () async {
                    //Implement login functionality.
                    if (code != null && code.length == 6) {
                      _authenicateWithOTP();
                    }
                  },
                  minWidth: media.width / 3,
                  height: 32.0,
                  child: Text(
                    'VERIFY',
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
