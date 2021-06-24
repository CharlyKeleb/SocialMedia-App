import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_media_app/services/user_service.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  User getCurrentUser() {
    User user = firebaseAuth.currentUser;
    return user;
  }

  Future<bool> createUser(
      {String name,
       // String password_confirmation,
      String email,
      String gender,
      String password}) async {

    final response = await http.post(
      Uri.parse('http://api.99huaren.local:3001/api/register'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': '$name',
        'email': '$email',
        'gender': '$gender',
        'password': '$password',
        // 'password_confirmation': '$password_confirmation',
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print(response.body);
      return false;
    }

    // var res = await firebaseAuth.createUserWithEmailAndPassword(
    //   email: '$email',
    //   password: '$password',
    // );
    // if (res.user != null) {
    //   await saveUserToFirestore(name, res.user, email, gender);
    //   return true;
    // } else {
    //   return false;
    // }
  }

  // saveUserToFirestore(
  //     String name, User user, String email, String gender) async {
  //   await usersRef.doc(user.uid).set({
  //     'username': name,
  //     'email': email,
  //     'time': Timestamp.now(),
  //     'id': user.uid,
  //     'bio': "",
  //     'gender': gender,
  //     'photoUrl': user.photoURL ?? ''
  //   });
  // }

  Future<bool> loginUser({String email, String password}) async {
    // use http to login user to 99huaren's back end service.

    final response = await http.post(
        Uri.parse('http://api.99huaren.local:3001/api/authorizations'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': '$email',
          'password': '$password'
        }),

    );
    if (response.statusCode == 201) {
      // If the server did return a 201 CREATED response,
      // then parse the JSON.
      final authResponse = AuthResponse.fromJson(jsonDecode(response.body));

// Create storage
      final storage = new FlutterSecureStorage();

// // Read value
//       String value = await storage.read(key: key);
//
// // Read all values
//       Map<String, String> allValues = await storage.readAll();
//
// // Delete value
//       await storage.delete(key: key);
//
// // Delete all
//       await storage.deleteAll();

// Write value
      await storage.write(key: 'access_token', value: authResponse.accessToken);

      UserService userService = UserService();
      userService.getCurrentUser();
      // save the token to the device
      return true;
    } else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to Login' + "${response.body}");
    }
    //log
    return true;
    // var res = await firebaseAuth.signInWithEmailAndPassword(
    //   email: '$email',
    //   password: '$password',
    // );
    //
    // if (res.user != null) {
    //   return true;
    // } else {
    //   return false;
    // }
  }

  forgotPassword(String email) async {
    await firebaseAuth.sendPasswordResetEmail(email: email);
  }

  logOut() async {
    await firebaseAuth.signOut();
  }

  String handleFirebaseAuthError(String e) {
    if (e.contains("ERROR_WEAK_PASSWORD")) {
      return "Password is too weak";
    } else if (e.contains("invalid-email")) {
      return "Invalid Email";
    } else if (e.contains("ERROR_EMAIL_ALREADY_IN_USE") ||
        e.contains('email-already-in-use')) {
      return "The email address is already in use by another account.";
    } else if (e.contains("ERROR_NETWORK_REQUEST_FAILED")) {
      return "Network error occured!";
    } else if (e.contains("ERROR_USER_NOT_FOUND") ||
        e.contains('firebase_auth/user-not-found')) {
      return "Invalid credentials.";
    } else if (e.contains("ERROR_WRONG_PASSWORD") ||
        e.contains('wrong-password')) {
      return "Invalid credentials.";
    } else if (e.contains('firebase_auth/requires-recent-login')) {
      return 'This operation is sensitive and requires recent authentication.'
          ' Log in again before retrying this request.';
    } else {
      return e;
    }
  }
}

class AuthResponse {
  final String accessToken;
  final int expiresIn;
  final String tokenType;

  AuthResponse({this.accessToken, this.expiresIn, this.tokenType});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['access_token'],
      expiresIn: json['expires_in'],
      tokenType: json['token_type'],
    );
  }
}

