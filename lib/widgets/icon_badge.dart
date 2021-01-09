import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/utils/firebase.dart';

class IconBadge extends StatefulWidget {
  final IconData icon;
  final double size;
  final Color color;

  IconBadge({Key key, @required this.icon, this.size, this.color})
      : super(key: key);

  @override
  _IconBadgeState createState() => _IconBadgeState();
}

class _IconBadgeState extends State<IconBadge> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Icon(
          widget.icon,
          size: widget.size,
          color: widget.color ?? null,
        ),
        Positioned(
          right: 0.0,
          child: Container(
            padding: EdgeInsets.all(1),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(6),
            ),
            constraints: BoxConstraints(
              minWidth: 11,
              minHeight: 11,
            ),
            child:
                Padding(padding: EdgeInsets.only(top: 1), child: buildCount()),
          ),
        ),
      ],
    );
  }

  buildCount() {
    StreamBuilder(
      stream: notificationRef
          .doc(firebaseAuth.currentUser.uid)
          .collection('notifications')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          QuerySnapshot snap = snapshot.data;
          List<DocumentSnapshot> docs = snap.docs;
          return buildTextWidget(docs?.length ?? 0.toString());
        } else {
          return buildTextWidget(0.toString());
        }
      },
    );
  }

  buildTextWidget(String counter) {
    return Text(
      counter,
      style: TextStyle(
        color: Colors.white,
        fontSize: 9,
      ),
      textAlign: TextAlign.center,
    );
  }
}
