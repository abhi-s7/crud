import 'package:crud/screens/home_screen.dart';
import 'package:crud/screens/login_screen.dart';
import 'package:crud/screens/verify_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FirebaseApp app = await Firebase.initializeApp();
  runApp(MyApp(app));
}

class MyApp extends StatelessWidget {
  final FirebaseApp app;
  final FirebaseAuth auth = FirebaseAuth.instance;
  MyApp(this.app);

  @override
  Widget build(BuildContext context) {
    return Provider<FirebaseApp>(
        create: (context) => app,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute:
              auth.currentUser != null ? HomeScreen.id : LoginScreen.id,
          routes: {
            LoginScreen.id: (context) => LoginScreen(),
            VerifyScreen.id: (context) => VerifyScreen(),
            HomeScreen.id: (context) => HomeScreen()
          },
        ));
  }
}
