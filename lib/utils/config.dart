import 'package:firebase_core/firebase_core.dart';

class Config {
  static initFirebase() async {
    await Firebase.initializeApp();
  }
}