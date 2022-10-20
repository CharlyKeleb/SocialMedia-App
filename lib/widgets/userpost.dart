import 'package:animations/animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:social_media_app/components/custom_card.dart';
import 'package:social_media_app/components/custom_image.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/pages/profile.dart';
import 'package:social_media_app/screens/comment.dart';
import 'package:social_media_app/screens/view_image.dart';
import 'package:social_media_app/services/post_service.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserPost extends StatelessWidget {
  final PostModel? post;

  UserPost({this.post});

  final DateTime timestamp = DateTime.now();

  currentUserId() {
    return firebaseAuth.currentUser!.uid;
  }

  final PostService services = PostService();

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      onTap: () {},
      borderRadius: BorderRadius.circular(10.0),
      child: OpenContainer(
        transitionType: ContainerTransitionType.fadeThrough,
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
                      height: 350.0,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                  Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.0, vertical: 5.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 0.0),
                          child: Row(
                            children: [
                              buildLikeButton(),
                              SizedBox(width: 5.0),
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
                        SizedBox(height: 5.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0.0),
                                child: StreamBuilder(
                                  stream: likesRef
                                      .where('postId', isEqualTo: post!.postId)
                                      .snapshots(),
                                  builder: (context,
                                      AsyncSnapshot<QuerySnapshot> snapshot) {
                                    if (snapshot.hasData) {
                                      QuerySnapshot snap = snapshot.data!;
                                      List<DocumentSnapshot> docs = snap.docs;
                                      return buildLikesCount(
                                          context, docs.length ?? 0);
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
                                  .doc(post!.postId!)
                                  .collection("comments")
                                  .snapshots(),
                              builder: (context,
                                  AsyncSnapshot<QuerySnapshot> snapshot) {
                                if (snapshot.hasData) {
                                  QuerySnapshot snap = snapshot.data!;
                                  List<DocumentSnapshot> docs = snap.docs;
                                  return buildCommentsCount(
                                      context, docs.length ?? 0);
                                } else {
                                  return buildCommentsCount(context, 0);
                                }
                              },
                            ),
                          ],
                        ),
                        Visibility(
                          visible: post!.description != null &&
                              post!.description.toString().isNotEmpty,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5.0, top: 3.0),
                            child: Text(
                              '${post?.description ?? ""}',
                              style: TextStyle(
                                color:
                                    Theme.of(context).textTheme.caption!.color,
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
                            timeago.format(post!.timestamp!.toDate()),
                            style: TextStyle(fontSize: 10.0),
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
          .where('postId', isEqualTo: post!.postId)
          .where('userId', isEqualTo: currentUserId())
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

          ///replaced this with an animated like button
          // return IconButton(
          //   onPressed: () {
          //     if (docs.isEmpty) {
          //       likesRef.add({
          //         'userId': currentUserId(),
          //         'postId': post!.postId,
          //         'dateCreated': Timestamp.now(),
          //       });
          //       addLikesToNotification();
          //     } else {
          //       likesRef.doc(docs[0].id).delete();
          //       services.removeLikeFromNotification(
          //           post!.ownerId!, post!.postId!, currentUserId());
          //     }
          //   },
          //   icon: docs.isEmpty
          //       ? Icon(
          //           CupertinoIcons.heart,
          //         )
          //       : Icon(
          //           CupertinoIcons.heart_fill,
          //           color: Colors.red,
          //         ),
          // );
          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              likesRef.add({
                'userId': currentUserId(),
                'postId': post!.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification();
              return !isLiked;
            } else {
              likesRef.doc(docs[0].id).delete();
              services.removeLikeFromNotification(
                  post!.ownerId!, post!.postId!, currentUserId());
              return isLiked;
            }
          }

          return LikeButton(
            onTap: onLikeButtonTapped,
            size: 25.0,
            circleColor:
                CircleColor(start: Color(0xffFFC0CB), end: Color(0xffff0000)),
            bubblesColor: BubblesColor(
                dotPrimaryColor: Color(0xffFFA500),
                dotSecondaryColor: Color(0xffd8392b),
                dotThirdColor: Color(0xffFF69B4),
                dotLastColor: Color(0xffff8c00)),
            likeBuilder: (bool isLiked) {
              return Icon(
                docs.isEmpty ? Ionicons.heart_outline : Ionicons.heart,
                color: docs.isEmpty
                    ? Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black
                    : Colors.red,
                size: 25,
              );
            },
          );
        }
        return Container();
      },
    );
  }

  addLikesToNotification() async {
    bool isNotMe = currentUserId() != post!.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc = await usersRef.doc(currentUserId()).get();
      user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      services.addLikesToNotification(
        "like",
        user!.username!,
        currentUserId(),
        post!.postId!,
        post!.mediaUrl!,
        post!.ownerId!,
        user!.photoUrl!,
      );
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

  buildUser(BuildContext context) {
    bool isMe = currentUserId() == post!.ownerId;
    return StreamBuilder(
      stream: usersRef.doc(post!.ownerId).snapshots(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          DocumentSnapshot snap = snapshot.data!;
          UserModel user =
              UserModel.fromJson(snap.data() as Map<String, dynamic>);
          return Visibility(
            visible: !isMe,
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 50.0,
                decoration: BoxDecoration(
                  color: Colors.white60,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    topRight: Radius.circular(10.0),
                  ),
                ),
                child: GestureDetector(
                  onTap: () => showProfile(context, profileId: user.id!),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        user.photoUrl!.isEmpty
                            ? CircleAvatar(
                                radius: 20.0,
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                child: Center(
                                  child: Text(
                                    '${user.username![0].toUpperCase()}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 20.0,
                                backgroundImage: CachedNetworkImageProvider(
                                  '${user.photoUrl}',
                                ),
                              ),
                        SizedBox(width: 5.0),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${post?.username ?? ""}',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${post?.location ?? 'Wooble'}',
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

  showProfile(BuildContext context, {String? profileId}) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) => Profile(profileId: profileId),
      ),
    );
  }
}
