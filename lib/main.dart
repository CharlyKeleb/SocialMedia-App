import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/landing/landing.dart';
import 'package:social_media_app/screens/mainscreen.dart';
import 'package:social_media_app/utils/config.dart';

//import 'package:social_media_app/screens/mainscreen.dart';
import 'package:social_media_app/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Config.initFirebase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: Constants.lightTheme,
      home: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
              if (snapshot.hasData) {
                return TabScreen();
              }
              return LandingPage();
            },
          ),
    );
  }

}
