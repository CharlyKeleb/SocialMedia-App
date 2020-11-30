import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
//import 'package:social_media_app/widgets/indicators.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
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
      body: Center(child: Text('Timeline'))
    );
  }
}