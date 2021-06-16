import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/services.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:http/http.dart' as http;

class UserService extends Service {
  String currentUid() {
    return firebaseAuth.currentUser.uid;
  }

  Future<LoggedUser> getCurrentUser() async {
    final storage = new FlutterSecureStorage();
    final accessToken = await storage.read(key: 'access_token');
    final response = await http.get(
      Uri.parse('http://api.99huaren.local:3001/api/user'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ' + accessToken
      },
    );
    if (response.statusCode == 200) {
      storage.write(key: 'logged_in_user', value: response.body);
    }else {
      // If the server did not return a 201 CREATED response,
      // then throw an exception.
      throw Exception('Failed to create album.');
    }

    }

  setUserStatus(bool isOnline) {
    var user = firebaseAuth.currentUser;
    if (user != null) {
      usersRef
          .doc(user.uid)
          .update({'isOnline': isOnline, 'lastSeen': Timestamp.now()});
    }
  }

  updateProfile(
      {File image, String username, String bio, String country}) async {
    DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
    var users = UserModel.fromJson(doc.data());
    users?.username = username;
    users?.bio = bio;
    users?.country = country;
    if (image != null) {
      users?.photoUrl = await uploadImage(profilePic, image);
    }
    await usersRef.doc(currentUid()).update({
      'username': username,
      'bio': bio,
      'country': country,
      "photoUrl": users?.photoUrl ?? '',
    });

    return true;
  }
}
/*
avatar: "http://www.hellowaresolutions.com/Content/img/logo.png"
created_at: "2021-04-03 03:19:52"
email: "info@hellowaresolutions.com"
id: 1
introduction: "Libero voluptatibus repellat eos non."
message_count: 0
name: "Summer"
notification_count: 0
pin_count: 0
public_email: true
settings: "{\"replyReverse\":true}"
wechat_connected: false
 */
class LoggedUser {
  final int id;
  final String avatar;
  final String createdAt;
  final String email;
  // final String introduction;

  LoggedUser({this.id, this.avatar, this.createdAt, this.email});

  factory LoggedUser.fromJson(Map<String, dynamic> json) {
    return LoggedUser(
      id: json['id'],
      avatar: json['avatar'],
      createdAt: json['created_at'],
      email: json['email'],
    );
  }
}
