import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/firebase.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  TextEditingController usernameTEC = TextEditingController();
  TextEditingController bioTEC = TextEditingController();
  TextEditingController countryTEC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  UserModel user;
  bool isEdit = false;
  bool loading = false;

  String currentUid() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      loading = true;
    });

    DocumentSnapshot doc = await usersRef.doc(currentUid()).get();
    user = UserModel.fromJson(doc.data());
    usernameTEC.text = user?.username;
    bioTEC.text = user?.bio;
    countryTEC.text = user?.country;
    setState(() {
      loading = false;
    });
    print(user?.username);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Edit Profile"),
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0),
              child: GestureDetector(
                onTap: save,
                child: isEdit
                    ? CircularProgressIndicator()
                    : Text(
                        'SAVE',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.0,
                          color: Theme.of(context).accentColor,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.transparent,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          offset: new Offset(0.0, 0.0),
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: CircleAvatar(
                        radius: 60.0,
                        backgroundImage: NetworkImage(user?.photoUrl),
                      ),
                    ),
                  ),
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      buildUsername(),
                      buildCountry(),
                      buildBio(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  buildUsername() {
    return Theme(
      data: ThemeData(primaryColor: Theme.of(context).accentColor),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          //initialValue: user.username,
          autovalidateMode: AutovalidateMode.onUserInteraction,

          controller: usernameTEC,
          decoration: InputDecoration(
            fillColor: Colors.grey[300],
            filled: true,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            prefixIcon: Icon(Feather.user),
            labelText: 'Username',
          ),
          validator: (String value) {
            if (value.length < 3) {
              return 'Username should be longer';
            }
            return null;
          },
        ),
      ),
    );
  }

  buildCountry() {
    return Theme(
      data: ThemeData(primaryColor: Theme.of(context).accentColor),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          controller: countryTEC,
          decoration: InputDecoration(
            fillColor: Colors.grey[300],
            filled: true,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            prefixIcon: Icon(Feather.user),
            labelText: 'Country',
          ),
        ),
      ),
    );
  }

  buildBio() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Bio",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextFormField(
            controller: bioTEC,
            maxLines: null,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            decoration: InputDecoration(
              hintText: "Update Bio",
            ),
            validator: (String value) {
              if (value.length > 1000) {
                return 'Bio too long';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  save() async {
    FormState form = formKey.currentState;
    form.save();
    if (!form.validate()) {
      SnackBar snackBar = SnackBar(
        content: Text("Fix the errors before you saving!"),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 3), () {});
    } else {
      setState(() {
        isEdit = true;
      });
      usersRef.doc(currentUid()).update({
        "username": usernameTEC.text,
        "country": countryTEC.text,
        "bio": bioTEC.text
      });
      SnackBar snackBar = SnackBar(
        content: Text("Profile Updated!"),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 3), () {
        Navigator.pop(context);
      });
      setState(() {
        isEdit = false;
      });
    }
  }
}
