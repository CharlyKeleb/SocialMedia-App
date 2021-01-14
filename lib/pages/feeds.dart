import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:social_media_app/chats/recent_chats.dart';
import 'package:social_media_app/components/stream_builder_wrapper.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/posts_view.dart';

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  currentUserId() {
    return firebaseAuth.currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Wooble'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(CupertinoIcons.chat_bubble_2_fill, size: 30.0,color:Theme.of(context).accentColor),
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => Chats()));
            },
          ),
          SizedBox(width: 20.0),
        ],
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          ///StoryView coming soon
       //   SliverAppBar(
            //expandedHeight: 115.0,
          //  flexibleSpace: FlexibleSpaceBar(
            //  background: StoryItems(),
          //  ),
          //),
          SliverList(
            delegate:
            SliverChildBuilderDelegate((BuildContext context, int index) {
              if (index > 0) return null;
              return StreamBuilderWrapper(
                shrinkWrap: true,
                stream: postRef
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (_, DocumentSnapshot snapshot) {
                  PostModel posts = PostModel.fromJson(snapshot.data());
                  return Padding(
                    padding: const EdgeInsets.only(
                        bottom: 15.0, left: 10.0, right: 10.0),
                    child: Posts(post: posts),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
