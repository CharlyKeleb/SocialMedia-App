import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/enum/message_type.dart';

class Register {
  String username;
  String email;
  String gender;
  String password;
  String passwordConfirmation;
  bool publicEmail = false;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.username;
    data['email'] = this.email;
    data['gender'] = this.gender;
    data['password'] = this.password;
    data['password_confirmation'] = this.passwordConfirmation;
    data['public_email'] = this.publicEmail;
    data['email'] = this.email;
    return data;
  }
}
