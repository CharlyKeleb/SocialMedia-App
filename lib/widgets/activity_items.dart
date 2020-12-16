import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/activity.dart';
import 'package:social_media_app/widgets/view_actvity_details.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'package:social_media_app/widgets/indicators.dart';

class ActivityItems extends StatefulWidget {
  final ActivityModel activity;
  ActivityItems({this.activity});

  @override
  _ActivityItemsState createState() => _ActivityItemsState();
}

class _ActivityItemsState extends State<ActivityItems> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ViewActivityDetails(activity: widget.activity),
            ));
          },
          leading: CircleAvatar(
            radius: 25.0,
            backgroundImage: NetworkImage(widget.activity.userDp),
          ),
          title: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
              ),
              children: [
                TextSpan(
                  text: '${widget.activity.username} ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.0),
                ),
                TextSpan(
                  text: buildTextConfiguration(),
                  style: TextStyle(fontSize: 10.0),
                ),
              ],
            ),
          ),
          subtitle: Text(
            timeago.format(widget.activity.timestamp.toDate()),
          ),
          trailing: previewConfiguration(),
        ),
        Divider(),
      ],
    );
  }

  previewConfiguration() {
    if (widget.activity.type == "like" || widget.activity.type == "comment") {
      return buildPreviewImage();
    } else {
      return Text('');
    }
  }

  buildTextConfiguration() {
    if (widget.activity.type == "like") {
      return "liked your post";
    } else if (widget.activity.type == "follow") {
      return "is following you";
    } else if (widget.activity.type == "comment") {
      return "commented '${widget.activity.commentData}'";
    } else {
      return "Error: Unknown type '${widget.activity.type}'";
    }
  }

  buildPreviewImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: CachedNetworkImage(
        imageUrl: widget.activity.mediaUrl,
        placeholder: (context, url) {
          return circularProgress(context);
        },
        errorWidget: (context, url, error) {
          return Icon(Icons.error);
        },
        height: 40.0,
        fit: BoxFit.cover,
        width: 40.0,
      ),
    );
  }
}
