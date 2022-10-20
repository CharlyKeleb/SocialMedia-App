import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/enum/message_type.dart';
import 'package:social_media_app/models/status.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/view_models/status/status_view_model.dart';
import 'package:social_media_app/widgets/indicators.dart';

class ConfirmStatus extends StatefulWidget {
  @override
  State<ConfirmStatus> createState() => _ConfirmStatusState();
}

class _ConfirmStatusState extends State<ConfirmStatus> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    StatusViewModel viewModel = Provider.of<StatusViewModel>(context);
    return Scaffold(
      body: LoadingOverlay(
        isLoading: loading,
        progressIndicator: circularProgress(context),
        child: Center(
          child: AspectRatio(
            aspectRatio: 9 / 16,
            child: Image.file(viewModel.mediaUrl!),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 10.0,
        child: Container(
          constraints: BoxConstraints(maxHeight: 100.0),
          child: Flexible(
            child: TextFormField(
              style: TextStyle(
                fontSize: 15.0,
                color: Theme.of(context).textTheme.headline6!.color,
              ),
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10.0),
                enabledBorder: InputBorder.none,
                border: InputBorder.none,
                hintText: "Type your caption",
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.headline6!.color,
                ),
              ),
              onSaved: (val) {
                viewModel.setDescription(val!);
              },
              onChanged: (val) {
                viewModel.setDescription(val);
              },
              maxLines: null,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(
          Icons.done,
          color: Colors.white,
        ),
        onPressed: () async {
          setState(() {
            loading = true;
          });
          //check if a user has uploaded a status
          QuerySnapshot snapshot = await statusRef
              .where('userId', isEqualTo: firebaseAuth.currentUser!.uid)
              .get();
          if (snapshot.docs.isNotEmpty) {
            List chatList = snapshot.docs;
            DocumentSnapshot chatListSnapshot = chatList[0];
            String url = await uploadMedia(viewModel.mediaUrl!);
            StatusModel message = StatusModel(
              url: url,
              caption: viewModel.description,
              type: MessageType.IMAGE,
              time: Timestamp.now(),
              statusId: uuid.v1(),
              viewers: [],
            );
            await viewModel.sendStatus(chatListSnapshot.id, message);
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
          } else {
            String url = await uploadMedia(viewModel.mediaUrl!);
            StatusModel message = StatusModel(
              url: url,
              caption: viewModel.description,
              type: MessageType.IMAGE,
              time: Timestamp.now(),
              statusId: uuid.v1(),
              viewers: [],
            );
            String id = await viewModel.sendFirstStatus(message);
            await viewModel.sendStatus(id, message);
            setState(() {
              loading = false;
            });
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<String> uploadMedia(File image) async {
    Reference storageReference =
        storage.ref().child("status").child(uuid.v1()).child(uuid.v4());
    UploadTask uploadTask = storageReference.putFile(image);
    await uploadTask.whenComplete(() => null);
    String imageUrl = await storageReference.getDownloadURL();
    return imageUrl;
  }
}
