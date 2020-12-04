import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
//import 'package:like_button/like_button.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/screens/comment.dart';
import 'package:social_media_app/screens/view_image.dart';
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
  final DateTime timestamp = DateTime.now();

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  bool isLiked;
  UserModel user;

  @override
  Widget build(BuildContext context) {
    isLiked = (widget.post?.likes[currentUserId()] == true);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => ViewImage(post: widget.post)));
      },
      child: Container(
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
              child: cachedNetworkImage(widget.post.mediaUrl),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              title: Text(
                widget.post.description,
                overflow: TextOverflow.ellipsis,
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
                      '  ${widget.post?.likesCount.toString()} likes',
                      style: TextStyle(
                          fontSize: 15.0, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              trailing: Wrap(children: [
                IconButton(
                  icon: isLiked
                      ? Icon(
                          CupertinoIcons.heart_fill,
                          color: Colors.red,
                        )
                      : Icon(CupertinoIcons.heart),
                  onPressed: handleLikePost,
                ),
                IconButton(
                  icon: Icon(
                    CupertinoIcons.chat_bubble,
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => Comments(post: widget.post),
                      ),
                    );
                  },
                ),
              ]),
            ),
          ],
        ),
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
      stream: usersRef.doc(widget.post.ownerId).snapshots(),
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

  handleLikePost() {
    bool _isLiked = widget.post?.likes[currentUserId()] == true;
    if (_isLiked) {
      postRef
          .doc(widget.post.ownerId)
          .collection('userPosts')
          .doc(widget.post.postId)
          .update({'likes.$currentUserId': false});
      removeLikeFromNotification();
      setState(() {
        widget.post.likesCount -= 1;
        isLiked = false;
        widget.post.likes[currentUserId()] = false;
      });
    } else if (!_isLiked) {
      postRef
          .doc(widget.post.ownerId)
          .collection('userPosts')
          .doc(widget.post.postId)
          .update({
        "likes": {currentUserId(): true}
      });
      addLikesToNotification();
      setState(() {
        widget.post.likesCount += 1;
        isLiked = true;
        widget.post.likes[currentUserId()] = true;
      });
    }
  }

  addLikesToNotification() async {
    bool isNotMe = currentUserId() != widget.post.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(widget.post.ownerId)
          .collection('notifications')
          .doc(widget.post.postId)
          .set({
        "type": "like",
        "username": user.username,
        "userId": currentUserId(),
        "userDp": user.photoUrl,
        "postId": widget.post.postId,
        "mediaUrl": widget.post.mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromNotification() async {
    bool isNotMe = currentUserId() != widget.post.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(widget.post.ownerId)
          .collection('notifications')
          .doc(widget.post.postId)
          .get()
          .then((doc) => {
                if (doc.exists) {doc.reference.delete()}
              });
    }
  }
}
