import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/auth/register/profile_pic.dart';
import 'package:social_media_app/models/register.dart';
import 'package:social_media_app/services/auth_service.dart';

class RegisterViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  Register registerModel = new Register();
  FocusNode usernameFN = FocusNode();
  FocusNode emailFN = FocusNode();
  FocusNode genderFN = FocusNode();
  FocusNode passFN = FocusNode();
  FocusNode cPassFN = FocusNode();
  AuthService auth = AuthService();

  register(BuildContext context) async {
    FormState form = formKey.currentState;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      if (registerModel.password == registerModel.passwordConfirmation) {
        loading = true;
        notifyListeners();
        try {
          bool success = await auth.createUser(
           registerModel
          );
          print(success);
          if (success) {
            showInSnackBar('user created');
            // Navigator.of(context).pushReplacement(
            //     CupertinoPageRoute(builder: (_) => ProfilePicture()));
          }
        } catch (e) {
          loading = false;
          notifyListeners();
          print(e);
          showInSnackBar('${auth.handleFirebaseAuthError(e.toString())}');
        }
        loading = false;
        notifyListeners();
      } else {
        showInSnackBar('The passwords does not match');
      }
    }
  }

  setEmail(val) {
    registerModel.email = val;
    notifyListeners();
  }

  setPublicEmail(val) {
    registerModel.publicEmail = val;
    notifyListeners();
  }

  setPassword(val) {
    registerModel.password = val;
    notifyListeners();
  }

  setName(val) {
    registerModel.username = val;
    notifyListeners();
  }

  setConfirmPass(val) {
    registerModel.passwordConfirmation = val;
    notifyListeners();
  }

  setGender(val) {
    registerModel.gender = val;
    notifyListeners();
  }

  void showInSnackBar(String value) {
    scaffoldKey.currentState.removeCurrentSnackBar();
    scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }
}
