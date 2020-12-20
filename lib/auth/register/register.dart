import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_media_app/auth/login/login.dart';
import 'package:social_media_app/auth/profile_pic.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool validate = false;
  bool loading = false;
  bool obsecureText = true;
  final DateTime timestamp = DateTime.now();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> registerKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Register'.toUpperCase(),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.only(left: 5.0, right: 5.0, top: 20.0),
        children: [
          Text(
            'Create a new account on FlutterSocial',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          buildForm(),
        ],
      ),
    );
  }

  buildForm() {
    return Form(
      key: registerKey,
      child: Column(
        children: [
          buildUsername(),
          buildEmail(),
          buildCountry(),
          buildPassword(),
          SizedBox(
            height: 10.0,
          ),
          loading
              ? CircularProgressIndicator()
              : Container(
                  height: 40.0,
                  width: 140.0,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Theme.of(context).accentColor,
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900),
                    ),
                    onPressed: () {
                      register();
                    },
                  ),
                ),
          SizedBox(height: 10.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Login()));
                },
                child: Text(
                  ' Login',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).accentColor,
                  ),
                ),
              ),
            ],
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
          controller: usernameController,
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

  buildEmail() {
    return Theme(
      data: ThemeData(primaryColor: Theme.of(context).accentColor),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          controller: emailController,
          decoration: InputDecoration(
            fillColor: Colors.grey[300],
            filled: true,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            prefixIcon: Icon(Feather.mail),
            labelText: 'Email',
          ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Email is Required';
            }
            if (!RegExp(
                    r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$")
                .hasMatch(value)) {
              return 'Please enter a valid Email';
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
          controller: countryController,
          decoration: InputDecoration(
            fillColor: Colors.grey[300],
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            prefixIcon: Icon(Feather.map_pin),
            labelText: 'Country',
          ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'This field must not be empty';
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget buildPassword() {
    return Theme(
      data: ThemeData(primaryColor: Theme.of(context).accentColor),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          controller: passwordController,
          keyboardType: TextInputType.visiblePassword,
          decoration: InputDecoration(
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
            fillColor: Colors.grey[300],
            filled: true,
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() => obsecureText = !obsecureText);
              },
              child: Icon(obsecureText ? Feather.eye : Feather.eye_off),
            ),
            prefixIcon: Icon(Feather.lock),
            labelText: 'Password',
          ),
          validator: (String value) {
            if (value.isEmpty) {
              return 'Password is Required';
            } else if (value.length < 4) {
              return "Password must be atleast 4 character";
            }
            return null;
          },
          //  onSaved: (String value) {
          //   _password = value;
          // },
          obscureText: obsecureText,
        ),
      ),
    );
  }

  register() async {
    FormState form = registerKey.currentState;
    form.save();
    if (!form.validate()) {
      validate = true;
      Fluttertoast.showToast(
        msg: "Fix the Errors before submitting.",
        textColor: Colors.white,
        backgroundColor: Colors.black,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
      );
    } else {
      setState(() {
        loading = true;
      });
      auth
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((result) {
        User user = result.user;
        firestore.collection('users').doc(user.uid).set({
          "username": usernameController.text,
          "email": emailController.text,
          "country": countryController.text,
          "bio": "",
          "time": timestamp,
          "photoUrl": user.photoURL,
          "id": user.uid
        }).then((val) {
          setState(() {
            loading = false;
          });
          SnackBar snackBar = SnackBar(
            content: Text("Registered Successfully!"),
          );
          scaffoldKey.currentState.showSnackBar(snackBar);
          Timer(Duration(seconds: 3), () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return ProfilePicture();
                },
              ),
            );
          });
        }).catchError((e) {
          print(e);
          setState(() {
            loading = false;
          });
        });
      }).catchError((e) {
        print(e);
        Fluttertoast.showToast(
          msg: '${handleFirebaseAuthError(e.toString())}',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
        );
         setState(() {
            loading = false;
          });
      });
    }
  }

  String handleFirebaseAuthError(String e) {
    if (e.contains("ERROR_WEAK_PASSWORD")) {
      return "Password is too weak";
    } else if (e.contains("ERROR_INVALID_EMAIL")) {
      return "Invalid Email";
    } else if (e.contains("ERROR_EMAIL_ALREADY_IN_USE")) {
      return "The email address is already in use by another account.";
    } else if (e.contains("ERROR_NETWORK_REQUEST_FAILED")) {
      return "Network error occurred!";
    } else if (e.contains("ERROR_USER_NOT_FOUND")) {
      return "Invalid credentials.";
    } else if (e.contains("ERROR_WRONG_PASSWORD")) {
      return "Invalid credentials.";
    } else {
      return e;
    }
  }
}
