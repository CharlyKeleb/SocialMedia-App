import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/auth/register/register.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/view_models/theme/theme_view_model.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(Icons.keyboard_backspace),
        ),
        elevation: 0.0,
        title: Text(
          "Settings",
          style: TextStyle(),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            ListTile(
              title: Text(
                "About",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text(
                "A Fully Functional Social Media Application Made by CharlyKeleb",
              ),
              trailing: Icon(Icons.error),
            ),
            Divider(),
            ListTile(
              title: Text(
                "Dark Mode",
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
              subtitle: Text("Use the dark mode"),
              trailing: Consumer<ThemeProvider>(
                builder: (context, notifier, child) => CupertinoSwitch(
                  onChanged: (val) {
                    notifier.toggleTheme();
                  },
                  value: notifier.dark,
                  activeColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
            Divider(),
            ListTile(
              onTap: () async {
                await firebaseAuth.signOut();
                Navigator.of(context).pushReplacement(
                  CupertinoPageRoute(
                    builder: (_) => Register(),
                  ),
                );
              },
              subtitle: Text(
                "Logout",
                style: TextStyle(
                  fontSize: 22.0,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              trailing: Icon(
                Icons.chevron_right,
                size: 30.0,
                color: Theme.of(context).iconTheme.color,
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}
