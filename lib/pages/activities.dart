import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('FlutterSocial'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Feather.message_circle),
            onPressed: () {},
          ),
          SizedBox(width: 20.0),
        ],
      ),
      body: Center(child: Text('activity')),
    );
  }
}
