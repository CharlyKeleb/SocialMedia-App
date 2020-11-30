import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class Posts extends StatefulWidget {
  final PostModel post;

  Posts({this.post});

  @override
  _PostsState createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          buildPostHeader(),
          Container(
            height: 320.0,
            width: MediaQuery.of(context).size.width - 20.0,
            child: cachedNetworkImage(widget.post.mediaUrl)
          ),
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
            title: Text(
              widget.post.description,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.0),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Text(
                    timeago.format(widget.post.timestamp.toDate()),
                  ),
                  SizedBox(width: 3.0),
                  Text(
                    '- ${widget.post?.likes.toString() ?? 0.toString()} likes',
                    style:
                        TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                  )
                ],
              ),
            ),
            trailing: Wrap(children: [
              IconButton(
                icon: Icon(
                  CupertinoIcons.heart,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  CupertinoIcons.chat_bubble,
                ),
                onPressed: () {},
              ),
            ]),
          )
        ],
      ),
    );
  }

  buildPostHeader() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
      leading: buildUserDp(),
      title: Text(
        widget.post.username,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        widget.post.location,
      ),
      trailing: IconButton(
        icon: Icon(Feather.more_horizontal),
        onPressed: () {},
      ),
    );
  }

  buildUserDp() {
    return StreamBuilder(
      stream: usersRef.doc(currentUserId()).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          UserModel user = UserModel.fromJson(snapshot.data.data());
          return CircleAvatar(
            radius: 25.0,
            backgroundImage: NetworkImage(user.photoUrl),
          );
        }
        return Container();
      },
    );
  }
}
