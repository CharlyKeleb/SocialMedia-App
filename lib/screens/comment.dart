import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/components/stream_comments_wrapper.dart';
import 'package:social_media_app/models/comments.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/cached_image.dart';
import 'package:timeago/timeago.dart' as timeago;

class Comments extends StatefulWidget {
  final PostModel post;

  Comments({this.post});

  _CommentsState createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  UserModel user;

  final DateTime timestamp = DateTime.now();
  TextEditingController commentsTEC = TextEditingController();

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.xmark_circle_fill,
          ),
        ),
        centerTitle: true,
        title: Text('Comments'),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Flexible(
              child: ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: buildFullPost(),
                  ),
                  Divider(thickness: 1.5),
                  Flexible(
                    child: buildComments(),
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                constraints: BoxConstraints(
                  maxHeight: 190.0,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Flexible(
                      child: ListTile(
                        contentPadding: EdgeInsets.all(0),
                        title: TextField(
                          textCapitalization: TextCapitalization.sentences,
                          controller: commentsTEC,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: Theme.of(context).textTheme.headline6.color,
                          ),
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            hintText: "Write your comment...",
                            hintStyle: TextStyle(
                              fontSize: 15.0,
                              color:
                                  Theme.of(context).textTheme.headline6.color,
                            ),
                          ),
                          maxLines: null,
                        ),
                        trailing: GestureDetector(
                          onTap: addComments,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Icon(
                              Icons.send,
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                        ),
                      ),
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

  buildFullPost() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment:MainAxisAlignment.start,
      crossAxisAlignment:CrossAxisAlignment.start,
      children: [
        Container(
          height: 250.0,
          width: MediaQuery.of(context).size.width - 20.0,
          child: cachedNetworkImage(widget.post.mediaUrl),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
           
            children: [
              Column(
                mainAxisAlignment:MainAxisAlignment.start,
      crossAxisAlignment:CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.description,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Row(
                    children: [
                      Text(
                        timeago.format(widget.post.timestamp.toDate()),
                        style: TextStyle(),
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
                    ],
                  ),
                ],
              ),
              Spacer(),
              buildLikeButton(),
            ],
          ),
        ),
        // ListTile(
        //     contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
        //     title: Text(
        //       widget.post.description,
        //       style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.0),
        //     ),
        //     subtitle: Padding(
        //       padding: const EdgeInsets.only(top: 8.0),
        //       child: Row(
        //         children: [
        //           Text(
        //             timeago.format(widget.post.timestamp.toDate()),style:TextStyle(),
        //           ),
        //           SizedBox(width: 3.0),
        //           StreamBuilder(
        //             stream: likesRef
        //                 .where('postId', isEqualTo: widget.post.postId)
        //                 .snapshots(),
        //             builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        //               if (snapshot.hasData) {
        //                 QuerySnapshot snap = snapshot.data;
        //                 List<DocumentSnapshot> docs = snap.docs;
        //                 return buildLikesCount(context, docs?.length ?? 0);
        //               } else {
        //                 return buildLikesCount(context, 0);
        //               }
        //             },
        //           ),
        //         ],
        //       ),
        //     ),
        //     trailing: buildLikeButton()),
      ],
    );
  }

  addComments() async {
    DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
    user = UserModel.fromJson(doc.data());
    commentRef.doc(widget.post.postId).collection("comments").add({
      "username": user.username,
      "comment": commentsTEC.text,
      "timestamp": timestamp,
      "userDp": user.photoUrl,
      "userId": user.id,
    });

    bool isNotMe = widget.post.ownerId != currentUserId();
    if (isNotMe) {
      notificationRef.doc(widget.post.ownerId).collection('notifications').add({
        "type": "comment",
        "commentData": commentsTEC.text,
        "username": user.username,
        "userId": user.id,
        "userDp": user.photoUrl,
        "postId": widget.post.postId,
        "mediaUrl": widget.post.mediaUrl,
        "timestamp": timestamp,
      });
    }
    commentsTEC.clear();
  }

  buildComments() {
    return CommentsStreamWrapper(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      stream: commentRef
          .doc(widget.post.postId)
          .collection('comments')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (_, DocumentSnapshot snapshot) {
        CommentModel comments = CommentModel.fromJson(snapshot.data());
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 20.0),
              leading: CircleAvatar(
                radius: 20.0,
                backgroundImage: NetworkImage(comments.userDp),
              ),
              title: Text(
                comments.username,
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                timeago.format(comments.timestamp.toDate()),
                style: TextStyle(fontSize: 12.0),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                comments.comment,
                style: TextStyle(fontWeight: FontWeight.w400),
              ),
            ),
            Divider()
          ],
        );
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
