import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/screens/mainscreen.dart';
import 'package:social_media_app/utils/firebase.dart';

class ProfilePicture extends StatefulWidget {
  @override
  _ProfilePictureState createState() => _ProfilePictureState();
}

class _ProfilePictureState extends State<ProfilePicture> {
  File _image;
  final picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool loading = false;
  Map userData;
  bool dataLoading = true;

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  currentUser() {
    return firebaseAuth.currentUser;
  }

  getUser() async {
    User user = await currentUser();
    DocumentSnapshot snapshot =
        await firestore.collection("users").doc(user.uid).get();
    userData = snapshot.data();
    dataLoading = false;
    setState(() {});
  }

  uploadImage() async {
    setState(() {
      loading = true;
    });
    User user = await currentUser();
    Reference storageReference =
        storage.ref().child("profilePictures/${user.uid}.jpg");
    UploadTask uploadTask = storageReference.putFile(_image);
    await uploadTask.whenComplete(() async {
      String imgUrl = await storageReference.getDownloadURL();
      firestore.collection("users").doc(user.uid).update({
        "photoUrl": imgUrl,
      });
      setState(() {
        loading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (_) => TabScreen()));
    });
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Upload  Profile Picture".toUpperCase(),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 50.0),
          Center(
            child: dataLoading
                ? CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _buildImage(),
                    ],
                  ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
            child: _image == null
                ? SizedBox()
                : loading
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        color: Theme.of(context).accentColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Center(
                          child: Text('NEXT'),
                        ),
                        onPressed: () => uploadImage(),
                      ),
          ),
        ],
      ),
    );
  }

  _buildImage() {
    print(userData);
    String pic = userData['profilePic'];
    if (pic != null) {
      return GestureDetector(
        onTap: () => getImage(),
        child: CircleAvatar(
          radius: 80,
          backgroundImage: NetworkImage(
            userData['profilePic'],
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => getImage(),
        child: _image == null
            ? CircleAvatar(
                radius: 100,
                child: Icon(
                  Feather.image,
                ),
              )
            : CircleAvatar(
                radius: 100,
                backgroundImage: FileImage(
                  _image,
                ),
              ),
      );
    }
  }
}
