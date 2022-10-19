import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/story_model.dart';
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
    String? description,
    required Map? count,
    required BuildContext context,
  }) async {
    try {
      List<String> ids = [];

      String uid = userService.currentUid();
      String imageUrl = await uploadImage(statuses, statusImage);
      await usersRef.get().then((QuerySnapshot snapshot) {
        snapshot.docs.forEach((DocumentSnapshot documentSnapshot) {
          ids.add(documentSnapshot.get('id'));
        });
      });
      List<String> statusDescriptions = [];
      List<String> statusImageUrls = [];
      List<List<String>> viewCounts = [];

      var statusesSnapshot = await statusRef
          .where(
            'uid',
            isEqualTo: userService.currentUid(),
          )
          .get();

      if (statusesSnapshot.docs.isNotEmpty) {
        Status status = Status.fromMap(
            statusesSnapshot.docs[0].data() as Map<String, dynamic>);
        statusDescriptions = status.description!;
        statusImageUrls = status.photoUrl;
        statusImageUrls.add(imageUrl);
        statusDescriptions.add(description!);
        await statusRef.doc(statusesSnapshot.docs[0].id).update({
          'photoUrl': statusImageUrls,
        });
        await statusRef.doc(statusesSnapshot.docs[0].id).update({
          'description': statusDescriptions,
        });
        await statusRef.doc(statusesSnapshot.docs[0].id).update({
          'viewCount': viewCounts,
        });
        return;
      } else {
        statusImageUrls = [imageUrl];
        statusDescriptions = [description!];
      }

      Status status = Status(
        uid: uid,
        username: username,
        description: statusDescriptions,
        photoUrl: statusImageUrls,
        createdAt: Timestamp.now(),
        profilePic: profilePic,
        statusId: statusId,
        whoCanSee: ids,
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
