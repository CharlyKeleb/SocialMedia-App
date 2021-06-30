import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:social_media_app/chats/recent_chats.dart';
import 'package:social_media_app/components/stream_builder_wrapper.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/userpost.dart';

class Timeline extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Wooble',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.chat_bubble_2_fill,
              size: 30.0,
              color: Theme.of(context).accentColor,
            ),
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (_) => Chats(),
                ),
              );
            },
          ),
          SizedBox(width: 20.0),
        ],
      ),
      body: ListView(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        children: [
          StreamBuilderWrapper(
            shrinkWrap: true,
            stream: postRef.orderBy('timestamp', descending: true).limit(3).snapshots(),
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (_, DocumentSnapshot snapshot) {
              internetChecker(context);
              PostModel posts = PostModel.fromJson(snapshot.data());
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: UserPost(post: posts),
              );
            },
          ),
        ],
      ),
    );
  }

  internetChecker(context) async {
    bool result = await DataConnectionChecker().hasConnection;
    if (result == false) {
      showInSnackBar('No Internet Connecton', context);
    }
  }

  void showInSnackBar(String value, context) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
