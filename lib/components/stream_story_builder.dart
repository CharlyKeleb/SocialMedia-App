import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/widgets/indicators.dart';

typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  DocumentSnapshot doc,
);

class StreamStoriesWrapper extends StatelessWidget {
  final Stream<dynamic> stream;
  final ItemBuilder<DocumentSnapshot> itemBuilder;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final bool reverse;
  final ScrollPhysics physics;
  final EdgeInsets padding;
  

  const StreamStoriesWrapper({
    Key key,
    @required this.stream,
    @required this.itemBuilder,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.reverse,
    this.physics = const ClampingScrollPhysics(),
    this.padding = const EdgeInsets.only(bottom: 2.0, left: 2.0),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var list = snapshot.data.docs.toList();
          return list.length == 0
              ? SizedBox()
              : ListView.builder(
                  padding: padding,
                  scrollDirection: scrollDirection,
                  itemCount: list.length + 1,
                  shrinkWrap: shrinkWrap,
                  reverse: reverse,
                  physics: physics,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == list.length) {
                      return buildUploadButton();
                    }

                    return itemBuilder(context, list[index]);
                  },
                );
        } else {
          return circularProgress(context);
        }
      },
    );
  }

  buildUploadButton() {
    return Padding(
      padding: EdgeInsets.all(7.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
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
          child: Padding(
            padding: const EdgeInsets.all(0.5),
            child: CircleAvatar(
              radius: 25.0,
              backgroundColor: Colors.grey[300],
              child: Center(
                child: Icon(Icons.add, color: Colors.blue),
              ),
            ),
          ),
      ),
    );
  }
}
