import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as Img;
import 'package:uuid/uuid.dart';

class Publication extends StatefulWidget {
  @override
  _PublicationState createState() => _PublicationState();
}

class _PublicationState extends State<Publication> {
  final DateTime timestamp = DateTime.now();

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  File file;
  String postId = Uuid().v4();
  bool isUploading = false;
  Position position;
  Placemark placemark;
  UserModel user;
  FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController locationTEC = TextEditingController();
  TextEditingController captionTEC = TextEditingController();

  handleCamera() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 600.0,
      maxWidth: 500.0,
    );
    setState(() {
      this.file = file;
    });
  }

  handleGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      maxHeight: 600.0,
      maxWidth: 500.0,
    );
    setState(() {
      this.file = file;
    });
  }

  clearPost() {
    setState(() {
      file = null;
    });
  }

  handlePost() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    print(mediaUrl);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationTEC.text,
      description: captionTEC.text,
    );

    captionTEC.clear();
    locationTEC.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  Future<String> uploadImage(imgFile) async {
    Reference storageReference = storage.ref().child("posts/$postId.jpg");

    UploadTask uploadTask =
        storageReference.child("posts/$postId.jpg").putFile(imgFile);
    TaskSnapshot storageSnap = await uploadTask.whenComplete(() => null);
    String imgUrl = await storageSnap.ref.getDownloadURL();
    return imgUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    user = UserModel.fromJson(doc.data());
    postRef.doc(currentUserId()).collection('userPosts').doc(postId).set({
      "postId": postId,
      "username": user.username,
      "ownerId": currentUserId(),
      "mediaUrl": mediaUrl,
      "description": description,
      "location": location,
      "timestamp": timestamp,
      "likes": {}
    }).catchError((e) {
      print(e);
    });
    // feedsRef.add({
      
    // });
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Img.Image imgFile = Img.decodeImage(file.readAsBytesSync());
    final compressedImage = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Img.encodeJpg(imgFile, quality: 100));
    setState(() {
      file = compressedImage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: file == null ? buildSplash() : buildUpload(),
    );
  }

  Future<void> showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              'Create Post',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  onTap: handleCamera,
                  title: Text(
                    'Upload from camera',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Feather.camera),
                ),
                Divider(),
                ListTile(
                  onTap: handleGallery,
                  title: Text(
                    'Upload from gallery',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(Feather.image),
                ),
                Divider(),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  buildSplash() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Icon(
              CupertinoIcons.camera_on_rectangle,
              size: 100.0,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 50.0),
            child: RaisedButton(
              color: Theme.of(context).accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'Upload a Post'.toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              onPressed: () => showMyDialog(),
            ),
          ),
        ],
      ),
    );
  }

  Scaffold buildUpload() {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: clearPost,
          child: Icon(Feather.x),
        ),
        centerTitle: true,
        title: Text(
          'CAPTION POST',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Feather.send),
            color: Theme.of(context).accentColor,
            onPressed: isUploading ? null : () => handlePost(),
          )
        ],
      ),
      body: ListView(
        children: [
          isUploading ? linearProgress(context) : SizedBox(),
          StreamBuilder(
            stream: usersRef.doc(currentUserId()).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                UserModel user = UserModel.fromJson(snapshot.data.data());
                return ListTile(
                  leading: CircleAvatar(
                    radius: 25.0,
                    backgroundImage: NetworkImage(user?.photoUrl),
                  ),
                  title: Text(
                    user?.username,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    user?.email,
                  ),
                );
              }
              return Container();
            },
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 260.0,
              width: MediaQuery.of(context).size.width - 20.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(file),
                ),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
            title: Container(
              width: 250.0,
              child: TextField(
                controller: locationTEC,
                decoration: InputDecoration(
                  hintText: "Enter your location",
                  border: InputBorder.none,
                ),
              ),
            ),
            trailing: IconButton(
              tooltip: "Use your current location",
              icon: Icon(Icons.pin_drop_rounded),
              iconSize: 30.0,
              color: Theme.of(context).accentColor,
              onPressed: getLocation,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
            child: TextField(
              controller: captionTEC,
              maxLines: null,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.all(0.0),
                  hintText: 'Write your caption...',
                  border: InputBorder.none),
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ],
      ),
    );
  }

  getLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print(permission);
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      LocationPermission rPermission = await Geolocator.requestPermission();
      print(rPermission);
      await getLocation();
    } else {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      placemark = placemarks[0];
      String city = " ${placemarks[0].locality}, ${placemarks[0].country}";
      locationTEC.text = city;
      print(city);
    }
  }
}
