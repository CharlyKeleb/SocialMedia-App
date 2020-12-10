import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/utils/firebase.dart';
import 'package:social_media_app/widgets/indicators.dart';
import 'package:timeago/timeago.dart' as timeago;

class ViewImage extends StatefulWidget {
  final PostModel post;

  ViewImage({this.post});

  @override
  _ViewImageState createState() => _ViewImageState();
}

final DateTime timestamp = DateTime.now();

currentUserId() {
  return firebaseAuth.currentUser.uid;
}

bool isLiked;
UserModel user;

class _ViewImageState extends State<ViewImage> {
  @override
  Widget build(BuildContext context) {
    isLiked = (widget.post?.likes[currentUserId()] == true);

    return Scaffold(
      //appBar: header(context),
      body: Center(
        child: buildImage(context),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        color: Colors.transparent,
        child: ListTile(
          title: Text(
            widget.post.username,
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Row(
            children: [
              Icon(Feather.clock, size: 13.0),
              SizedBox(width: 3.0),
              Text(timeago.format(widget.post.timestamp.toDate())),
            ],
          ),
          trailing: IconButton(
            icon: isLiked
                ? Icon(
                    CupertinoIcons.heart_fill,
                    color: Colors.red,
                  )
                : Icon(CupertinoIcons.heart),
            onPressed: handleLikePost,
          ),
        ),
      ),
    );
  }

  buildImage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5.0),
        child: CachedNetworkImage(
          imageUrl: widget.post.mediaUrl,
          placeholder: (context, url) {
            return circularProgress(context);
          },
          errorWidget: (context, url, error) {
            return Icon(Icons.error);
          },
          height: 400.0,
          fit: BoxFit.cover,
          width: MediaQuery.of(context).size.width,
        ),
      ),
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
