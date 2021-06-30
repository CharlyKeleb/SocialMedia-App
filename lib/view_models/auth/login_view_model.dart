import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/screens/mainscreen.dart';
import 'package:social_media_app/services/auth_service.dart';
import 'package:social_media_app/utils/validation.dart';

class LoginViewModel extends ChangeNotifier {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool validate = false;
  bool loading = false;
  String email, password;
  FocusNode emailFN = FocusNode();
  FocusNode passFN = FocusNode();
  AuthService auth = AuthService();

  login(BuildContext context) async {
    FormState form = formKey.currentState;
    form.save();
    if (!form.validate()) {
      validate = true;
      notifyListeners();
      showInSnackBar('Please fix the errors in red before submitting.',context);
    } else {
      loading = true;
      notifyListeners();
      try {
        bool success = await auth.loginUser(
          email: email,
          password: password,
        );
        print(success);
        if (success) {
          Navigator.of(context).pushReplacement(
              CupertinoPageRoute(builder: (_) => TabScreen()));
        }
      } catch (e) {
        loading = false;
        notifyListeners();
        print(e);
        showInSnackBar('${auth.handleFirebaseAuthError(e.toString())}',context);
      }
      loading = false;
      notifyListeners();
    }
  }

  forgotPassword(BuildContext context) async {
    loading = true;
    notifyListeners();
    FormState form = formKey.currentState;
    form.save();
    print(Validations.validateEmail(email));
    if (Validations.validateEmail(email) != null) {
      showInSnackBar('Please input a valid email to reset your password.',context);
    } else {
      try {
        await auth.forgotPassword(email);
        showInSnackBar('Please check your email for instructions '
            'to reset your password', context);
      } catch (e) {
        showInSnackBar('${e.toString()}', context);
      }
    }
    loading = false;
    notifyListeners();
  }

  setEmail(val) {
    email = val;
    notifyListeners();
  }

  setPassword(val) {
    password = val;
    notifyListeners();
  }

  void showInSnackBar(String value,context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
