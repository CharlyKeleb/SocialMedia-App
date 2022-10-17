import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/story_model.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/services.dart';
import 'package:social_media_app/services/user_service.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:uuid/uuid.dart';

class StatusService extends Service {
  String statusId = const Uuid().v1();
  UserService userService = UserService();

  uploadStatus({
    required String username,
    required String profilePic,
    required File statusImage,
    required BuildContext context,
  }) async {
    try {
      String uid = userService.currentUid();
      String imageUrl = await uploadImage(statuses, statusImage);

      var allContacts = await usersRef.get().then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
          print(documentSnapshot.get('id'));
        });
      });
      print('All Contacts ${allContacts}');

      List<String> statusImageUrls = [];
      var statusesSnapshot = await statusRef
          .where(
            'uid',
            isEqualTo: userService.currentUid(),
          )
          .get();

      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(
            statusesSnapshot.docs[0].data() as Map<String, dynamic>);
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageUrl);
        await statusRef.doc(statusesSnapshot.docs[0].id).update({
          'photoUrl': statusImageUrls,
        });
        return;
      } else {
        statusImageUrls = [imageUrl];
      }

      Status status = Status(
        uid: uid,
        username: username,
        photoUrl: statusImageUrls,
        createdAt: DateTime.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: [],
      );

      await statusRef.doc(statusId).set(status.toMap());
      print('UPLOADED');
    } catch (e) {
      showSnackBar(e.toString(), context);
    }
  }

  Future<List<Status>> getStatus(BuildContext context) async {
    List<Status> statusData = [];

    try {
      QuerySnapshot allContacts = await usersRef.get();

      var statusesSnapshot = await statusRef.get();
      for (var tempData in statusesSnapshot.docs) {
        Status tempStatus =
            Status.fromMap(tempData.data() as Map<String, dynamic>);
        if (tempStatus.whoCanSee.contains(userService.currentUid())) {
          statusData.add(tempStatus);
        }
      }
    } catch (e) {
      if (kDebugMode) print(e);
      showSnackBar(e.toString(), context);
    }
    return statusData;
  }

  void showSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
