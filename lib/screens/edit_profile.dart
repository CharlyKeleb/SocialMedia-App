import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/view_models/profile/edit_profile_view_model.dart';
import 'package:social_media_app/widgets/indicators.dart';

class EditProfileDemo extends StatefulWidget {
  final UserModel user;

  const EditProfileDemo({this.user});
  @override
  _EditProfileDemoState createState() => _EditProfileDemoState();
}

class _EditProfileDemoState extends State<EditProfileDemo> {
  @override
  Widget build(BuildContext context) {
    EditProfileViewModel viewModel = Provider.of<EditProfileViewModel>(context);
    return ModalProgressHUD(
      progressIndicator: circularProgress(context),
      inAsyncCall: viewModel.loading,
      child: Scaffold(
        key: viewModel.scaffoldKey,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Edit Profile"),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 25.0),
                child: GestureDetector(
                  //    onTap: ,
                  child: Text(
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
        body: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: () => viewModel.pickImage(),
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
                  // child: Padding(
                  //   padding: const EdgeInsets.all(1.0),
                  //   child: CircleAvatar(
                  //     radius: 60.0,
                  //     backgroundImage: NetworkImage(user?.photoUrl),
                  //   ),
                  // ),
                  child: viewModel.imgLink != null
                      ? CircleAvatar(
                          radius: 60.0,
                          backgroundImage: NetworkImage(viewModel.imgLink),
                        )
                      : viewModel.image == null
                          ? CircleAvatar(
                              radius: 60.0,
                              child: Center(
                                child: Icon(CupertinoIcons.camera),
                              ),
                            )
                          : CircleAvatar(
                              radius: 60.0,
                              child: Image.file(
                                viewModel.image,
                              ),
                            ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
