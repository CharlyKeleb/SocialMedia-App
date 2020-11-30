import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:social_media_app/auth/register/register.dart';
import 'package:social_media_app/screens/mainscreen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool validate = false;
  bool loading = false;
  bool obsecureText = true;
  TextEditingController passwordTEC = TextEditingController();
  TextEditingController emailTEC = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        children: [
          SizedBox(height: 60.0),
          Container(
            height: 200.0,
            width: MediaQuery.of(context).size.width,
            child: Image.asset(
              'assets/images/login.png',
            ),
          ),
          SizedBox(height: 10.0),
          Center(
            child: Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Center(
            child: Text(
              'Log into your existing fluttersocial account',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w300,
                color: Theme.of(context).textTheme.caption.color,
              ),
            ),
          ),
          Divider(),
          SizedBox(height: 5.0),
          buildForm(),
          SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account?',
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Register()));
                },
                child: Text(
                  ' Sign Up',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
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

  buildForm() {
    return Form(
      key: formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildEmail(),
          buildpassWord(),
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
                        'Login',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w900),
                      ),
                      onPressed: () {
                        login();
                      }),
                ),
        ],
      ),
    );
  }

  buildEmail() {
    return Theme(
      data: ThemeData(primaryColor: Theme.of(context).accentColor),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          controller: emailTEC,
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

  Widget buildpassWord() {
    return Theme(
      data: ThemeData(primaryColor: Theme.of(context).accentColor),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: TextFormField(
          controller: passwordTEC,
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
          /*  onSaved: (String value) {
            _password = value;
          }, */

          obscureText: obsecureText,
        ),
      ),
    );
  }

  login() async {
    FormState form = formKey.currentState;
    form.save();
    if (!form.validate()) {
      SnackBar snackBar = SnackBar(
        content: Text("Fix the Errors before submitting."),
      );
      scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 3), () {});
    } else {
      setState(() {
        loading = true;
      });
      auth
          .signInWithEmailAndPassword(
              email: emailTEC.text, password: passwordTEC.text)
          .then((result) {
        User user = result.user;
        print(user);
        setState(() {
          loading = false;
        });
        SnackBar snackBar = SnackBar(
          content: Text("Welcome Back"),
        );
        scaffoldKey.currentState.showSnackBar(snackBar);
        Timer(Duration(seconds: 3), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) {
                return TabScreen();
              },
            ),
          );
        });
      }).catchError((e) {
        Fluttertoast.showToast(
          msg: '${handleFirebaseAuthError(e.toString())}',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
        );
        print(e.toString());
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

  @override
  void dispose() {
    emailTEC.dispose();
    super.dispose();
  }
}
