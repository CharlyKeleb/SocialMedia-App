import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/components/activity_stream_wrapper.dart';
import 'package:social_media_app/models/activity.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/activity_items.dart';

class Activities extends StatefulWidget {
  @override
  _ActivitiesState createState() => _ActivitiesState();
}

class _ActivitiesState extends State<Activities> {
  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Notifications'),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: Icon(Feather.x),
          //   onPressed: () {},
          // ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'CLEAR',
              style: TextStyle(
                fontSize: 13.0,
                  fontWeight: FontWeight.w900,
                  color: Theme.of(context).accentColor),
            ),
          ),
          // SizedBox(width: 20.0),
        ],
      ),
      body: ListView(
        children: [
          getActivities(),
        ],
      ),
    );
  }

  getActivities() {
    return ActivityStreamWrapper(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        stream: notificationRef
            .doc(currentUserId())
            .collection('notifications')
            .limit(20)
            .snapshots(),
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (_, DocumentSnapshot snapshot) {
          ActivityModel activities = ActivityModel.fromJson(snapshot.data());
          return ActivityItems(
            activity: activities,
          );
        });
  }
}
