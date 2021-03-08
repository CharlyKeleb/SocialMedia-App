import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';

//import 'package:like_button/like_button.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/pages/profile.dart';
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

  //UserModel user;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
            CupertinoPageRoute(builder: (_) => ViewImage(post: widget.post)));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildPostHeader(),
            Container(
              height: 320.0,
              width: MediaQuery.of(context).size.width - 18.0,
              child: cachedNetworkImage(widget.post.mediaUrl),
            ),
            Flexible(
              child: ListTile(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                title: Text(
                  widget.post.description == null
                      ? ""
                      : widget.post.description,
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
                      StreamBuilder(
                        stream: likesRef
                            .where('postId', isEqualTo: widget.post.postId)
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            QuerySnapshot snap = snapshot.data;
                            List<DocumentSnapshot> docs = snap.docs;
                            return buildLikesCount(context, docs?.length ?? 0);
                          } else {
                            return buildLikesCount(context, 0);
                          }
                        },
                      ),
                      SizedBox(width: 5.0),
                      StreamBuilder(
                        stream: commentRef
                            .doc(widget.post.postId)
                            .collection("comments")
                            .snapshots(),
                        builder:
                            (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            QuerySnapshot snap = snapshot.data;
                            List<DocumentSnapshot> docs = snap.docs;
                            return buildCommentsCount(
                                context, docs?.length ?? 0);
                          } else {
                            return buildCommentsCount(context, 0);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                trailing: Wrap(
                  children: [
                    buildLikeButton(),
                    IconButton(
                      icon: Icon(
                        CupertinoIcons.chat_bubble,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (_) => Comments(post: widget.post),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 7.0),
      child: Text(
        '$count likes',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 10.0,
        ),
      ),
    );
  }

  buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.5),
      child: Text(
        '-   $count comments',
        style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildPostHeader() {
    bool isMe = currentUserId() == widget.post.ownerId;
    return ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
        leading: buildUserDp(),
        title: Text(
    widget.post.username,
    style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
    widget.post.location == null ? 'Wooble' : widget.post.location,
        ),
        trailing: isMe
      ? IconButton(
          icon: Icon(Feather.more_horizontal),
          onPressed: () => handleDelete(context),
        )
      : IconButton(
          ///Feature coming soon
          icon: Icon(CupertinoIcons.bookmark, size: 25.0),
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
          return GestureDetector(
            onTap: () => showProfile(context, profileId: user?.id),
            child: CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(user.photoUrl),
            ),
          );
        }
        return Container();
      },
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: widget.post.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot?.data?.docs ?? [];
          return IconButton(
            onPressed: () {
              if (docs.isEmpty) {
                likesRef.add({
                  'userId': currentUserId(),
                  'postId': widget.post.postId,
                  'dateCreated': Timestamp.now(),
                });
                addLikesToNotification();
              } else {
                likesRef.doc(docs[0].id).delete();
                removeLikeFromNotification();
              }
            },
            icon: docs.isEmpty
                ? Icon(
                    CupertinoIcons.heart,
                  )
                : Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                  ),
          );
        }
        return Container();
      },
    );
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

  handleDelete(BuildContext parentContext) {
    //shows a simple dialog box
    return showDialog(
        context: parentContext,
        builder: (context) {
          return SimpleDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            children: [
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                  deletePost();
                },
                child: Text('Delete Post'),
              ),
              Divider(),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Cancel'),
              ),
            ],
          );
        });
  }

//you can only delete your own posts
  deletePost() async {
    postRef.doc(widget.post.id).delete();

//delete notification associated with that given post
    QuerySnapshot notificationsSnap = await notificationRef
        .doc(widget.post.ownerId)
        .collection('notifications')
        .where('postId', isEqualTo: widget.post.postId)
        .get();
    notificationsSnap.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

//delete all the comments associated with that given post
    QuerySnapshot commentSnapshot =
        await commentRef.doc(widget.post.postId).collection('comments').get();
    commentSnapshot.docs.forEach((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  showProfile(BuildContext context, {String profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }
}
