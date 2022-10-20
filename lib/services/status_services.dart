import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/status.dart';
import 'package:social_media_app/services/user_service.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:uuid/uuid.dart';

class StatusService {
  String statusId = const Uuid().v1();
  UserService userService = UserService();

  void showSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }

  sendStatus(StatusModel status, String chatId) async {
    //will send message to chats collection with the usersId
    await statusRef
        .doc("$chatId")
        .collection("statuses")
        .doc(status.statusId)
        .set(status.toJson());
    //will update "lastTextTime" to the last time a text was sent
    await statusRef.doc("$chatId").update({
      "userId": firebaseAuth.currentUser!.uid,
    });
  }

  Future<String> sendFirstStatus(StatusModel status) async {
    List<String> ids = [];
    await usersRef.get().then((QuerySnapshot snapshot) {
      snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
        ids.add(documentSnapshot.get('id'));
      });
    });
    User? user = firebaseAuth.currentUser;
    DocumentReference ref = await statusRef.add({
      'whoCanSee': ids,
    });
    await sendStatus(status, ref.id);
    return ref.id;
  }

  Future<String> uploadImage(File image) async {
    Reference storageReference =
        storage.ref().child("chats").child(uuid.v1()).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }
}
