import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import 'package:ionicons/ionicons.dart';
import 'package:like_button/like_button.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/post_service.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/view_models/auth/posts_view_model.dart';

class WoobleReels extends StatefulWidget {
  const WoobleReels({super.key});

  @override
  State<WoobleReels> createState() => _WoobleReelsState();
}

class _WoobleReelsState extends State<WoobleReels> {
  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        Provider.of<PostsViewModel>(context, listen: false).getReels();
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    PostsViewModel viewModel = Provider.of<PostsViewModel>(context);

    return Scaffold(
      body: PageView.builder(
        itemCount: viewModel.data.length,
        controller: PageController(
          viewportFraction: 1,
          initialPage: 0,
        ),
        scrollDirection: Axis.vertical,
        itemBuilder: (BuildContext context, int index) {
          PostModel posts = PostModel.fromJson(
            viewModel.data[index].data() as Map<String, dynamic>,
          );
          return Stack(
            children: [
              Image.asset(
                'assets/images/cm0.jpeg',
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
              Column(
                children: [
                  Container(
                    height: 100.0,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Reels',
                          style: GoogleFonts.amaranth(
                            fontSize: 30.0,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Container(
                            height: 120.0,
                            padding: EdgeInsets.symmetric(horizontal: 20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
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
                                          radius: 19.0,
                                          backgroundColor: Colors.white,
                                          child: CircleAvatar(
                                            radius: 18.0,
                                            backgroundColor: Colors.grey,
                                            backgroundImage: AssetImage(
                                              'assets/images/cm0.jpeg',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Text(
                                        'CharlyKeleb.dev',
                                        style: TextStyle(
                                          fontSize: 15.0,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Hi guys, we just rolled out a new release",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  height: 23.0,
                                  width: 150.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30.0),
                                    color: Colors.grey.withOpacity(0.6),
                                    border: Border.all(
                                      width: 0.5,
                                      color: Colors.white,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Iconsax.music,
                                          size: 12.0,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 10.0),
                                        Text(
                                          "Original Audio",
                                          style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        //reaction section
                        Container(
                          width: 100.0,
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 3.5,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Icon(
                                    Ionicons.heart,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                  SizedBox(height: 5.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 7.0),
                                    child: Text(
                                      '10 likes',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Icon(
                                    Iconsax.message,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                  SizedBox(height: 5.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 7.0),
                                    child: Text(
                                      '10 replies',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 20.0),
                                  Icon(
                                    CupertinoIcons.reply,
                                    color: Colors.white,
                                    size: 30.0,
                                  ),
                                  SizedBox(height: 5.0),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 7.0),
                                    child: Text(
                                      '10 shares',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          );
        },
      ),
    );
  }

  buildLikeButton(PostModel post, PostsViewModel viewModel) {
    return StreamBuilder(
      stream: likesRef
          .where('postId', isEqualTo: post!.postId)
          .where('userId', isEqualTo: firebaseAuth.currentUser!.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];

          Future<bool> onLikeButtonTapped(bool isLiked) async {
            if (docs.isEmpty) {
              likesRef.add({
                'userId': firebaseAuth.currentUser!.uid,
                'postId': post.postId,
                'dateCreated': Timestamp.now(),
              });
              addLikesToNotification(post, viewModel);
              return !isLiked;
            } else {
              likesRef.doc(docs[0].id).delete();
              viewModel.postService.removeLikeFromNotification(
                  post.ownerId!, post.postId!, firebaseAuth.currentUser!.uid);
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
              dotLastColor: Color(0xffff8c00),
            ),
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

  addLikesToNotification(PostModel post, PostsViewModel viewModel) async {
    bool isNotMe = firebaseAuth.currentUser!.uid != post.ownerId;

    if (isNotMe) {
      DocumentSnapshot doc =
          await usersRef.doc(firebaseAuth.currentUser!.uid).get();
      var user = UserModel.fromJson(doc.data() as Map<String, dynamic>);
      viewModel.postService.addLikesToNotification(
        "like",
        user.username ?? "",
        firebaseAuth.currentUser!.uid,
        post.postId ?? "",
        post.mediaUrl ?? "",
        post.ownerId ?? "",
        user.photoUrl ?? "",
      );
    }
  }

  buildLikesCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(left: 0.0, right: 5.0),
      child: Text(
        '$count likes',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12.5,
        ),
      ),
    );
  }

  buildCommentsCount(BuildContext context, int count) {
    return Padding(
      padding: const EdgeInsets.only(top: 0.5),
      child: Text(
        ' $count  comments',
        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
      ),
    );
  }
}
