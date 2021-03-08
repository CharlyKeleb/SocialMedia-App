import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/components/custom_card.dart';
import 'package:social_media_app/components/custom_image.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/pages/profile.dart';
import 'package:social_media_app/screens/comment.dart';
import 'package:social_media_app/screens/view_image.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserPost extends StatelessWidget {
  final PostModel post;

  UserPost({this.post});
  final DateTime timestamp = DateTime.now();

  currentUserId() {
    return firebaseAuth.currentUser.uid;
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: null,
      borderRadius: BorderRadius.circular(10.0),
      child: OpenContainer(
        //transitionType: ContainerTransitionType.fade,
        openBuilder: (BuildContext context, VoidCallback _) {
          return ViewImage(post: post);
        },
        closedElevation: 0.0,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        onClosed: (v) {},
        closedColor: Theme.of(context).cardColor,
        closedBuilder: (BuildContext context, VoidCallback openContainer) {
          return Stack(
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    child: CustomImage(
                      imageUrl: post?.mediaUrl ?? '',
                      height: 250.0,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal:5.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5.0),
                          child: Row(
                            children: [
                              buildLikeButton(),
                              InkWell(
                                borderRadius: BorderRadius.circular(10.0),
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (_) => Comments(post: post),
                                    ),
                                  );
                                },
                                child: Icon(
                                   CupertinoIcons.chat_bubble,
                                  size: 25.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5.0),
                                child: StreamBuilder(
                                  stream: likesRef
                                      .where('postId', isEqualTo: post.postId)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot snap = snapshot.data;
                                      List<DocumentSnapshot> docs = snap.docs;
                                      return buildLikesCount(
                                          context, docs?.length ?? 0);
                                    } else {
                                      return buildLikesCount(context, 0);
                                    }
                                  },
                                ),
                              ),
                            ),
                            SizedBox(width: 5.0),
                            StreamBuilder(
                              stream: commentRef
                                  .doc(post.postId)
                                  .collection("comments")
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
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
                        Visibility(
                          visible: post.description!= null &&
                              post.description.toString().isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0, top: 3.0),
                            child: Text(
                              '${post.description}',
                              style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption.color,
                                fontSize: 15.0,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                        SizedBox(height: 3.0),
                        Padding(
                          padding: const EdgeInsets.all(3.0),
                          child: Text(
                      timeago.format(post.timestamp.toDate()),style:TextStyle(fontSize:10.0)
                    ),
                        ),
                        // SizedBox(height: 5.0),
                      ],
                    ),
                  )
                ],
              ),
              buildUser(context),
            ],
          );
        },
      ),
    );
  }

  buildLikeButton() {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: post.postId)
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
                  'postId': post.postId,
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
    bool isNotMe = currentUserId() != post.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(post.ownerId)
          .collection('notifications')
          .doc(post.postId)
          .set({
        "type": "like",
        "username": user.username,
        "userId": currentUserId(),
        "userDp": user.photoUrl,
        "postId": post.postId,
        "mediaUrl": post.mediaUrl,
        "timestamp": timestamp,
      });
    }
  }

  removeLikeFromNotification() async {
    bool isNotMe = currentUserId() != post.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data());
      notificationRef
          .doc(post.ownerId)
          .collection('notifications')
          .doc(post.postId)
          .get()
          .then((doc) => {
                if (doc.exists) {doc.reference.delete()}
              });
    }
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
  // buildCommentsCount(BuildContext context, int count) {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 7.0),
  //     child: Text(
  //       '$count comments',
  //       style: TextStyle(
  //         color: Theme.of(context).textTheme.caption.color.withOpacity(0.4),
  //         fontSize: 10.0,
  //       ),
  //     ),
  //   );
  // }

  buildUser(BuildContext context) {
    bool isMe = currentUserId() == post.ownerId;
    return StreamBuilder(
      stream: usersRef.doc(post.ownerId).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot snap = snapshot.data;
          UserModel user = UserModel.fromJson(snap.data());
          return Visibility(
            visible: !isMe,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 40.0,
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: GestureDetector(
                             onTap: () => showProfile(context, profileId: user?.id),

                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        user.photoUrl.isNotEmpty
                            ? CircleAvatar(
                                radius: 14.0,
                                backgroundColor: Color(0xff4D4D4D),
                                backgroundImage:
                                    CachedNetworkImageProvider(user.photoUrl),
                              )
                            : CircleAvatar(
                                radius: 14.0,
                                backgroundColor: Color(0xff4D4D4D),
                              ),
                        SizedBox(width: 5.0),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${post.username}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xff4D4D4D),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${post.location == null ? 'Wooble' : post.location}',
                              style: TextStyle(
                                fontSize: 10.0,
                                color: Color(0xff4D4D4D),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
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


