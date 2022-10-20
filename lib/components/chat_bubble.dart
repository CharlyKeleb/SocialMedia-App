import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_3.dart';
import 'package:social_media_app/components/text_time.dart';
import 'package:social_media_app/models/enum/message_type.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatBubbleWidget extends StatefulWidget {
  final String? message;
  final MessageType? type;
  final Timestamp? time;
  final bool? isMe;

  ChatBubbleWidget({
    @required this.message,
    @required this.time,
    @required this.isMe,
    @required this.type,
  });

  @override
  _ChatBubbleWidgetState createState() => _ChatBubbleWidgetState();
}

class _ChatBubbleWidgetState extends State<ChatBubbleWidget> {
  Color? chatBubbleColor() {
    if (widget.isMe!) {
      return Theme.of(context).colorScheme.secondary;
    } else {
      if (Theme.of(context).brightness == Brightness.dark) {
        return Colors.grey[800];
      } else {
        return Colors.grey[200];
      }
    }
  }

  Color? chatBubbleReplyColor() {
    if (Theme.of(context).brightness == Brightness.dark) {
      return Colors.grey[600];
    } else {
      return Colors.grey[50];
    }
  }

  @override
  Widget build(BuildContext context) {
    final align =
        widget.isMe! ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = widget.isMe!
        ? BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    return Column(
      crossAxisAlignment: align,
      children: <Widget>[
        ChatBubble(
          elevation: 0.0,
          margin: const EdgeInsets.all(3.0),
          padding: const EdgeInsets.all(5.0),
          alignment:
              widget.isMe! ? Alignment.centerRight : Alignment.centerLeft,
          clipper: ChatBubbleClipper3(
            nipSize: 0,
            type: widget.isMe!
                ? BubbleType.sendBubble
                : BubbleType.receiverBubble,
          ),
          backGroundColor: chatBubbleColor(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding:
                    EdgeInsets.all(widget.type == MessageType.TEXT ? 10 : 0),
                child: widget.type == MessageType.TEXT
                    ? Text(
                        widget.message!,
                        style: TextStyle(
                          color: widget.isMe!
                              ? Colors.white
                              : Theme.of(context).textTheme.headline6!.color,
                        ),
                      )
                    : CachedNetworkImage(
                        imageUrl: "${widget.message}",
                        height: 200,
                        width: MediaQuery.of(context).size.width / 1.3,
                        fit: BoxFit.cover,
                      ),
              ),
            ],
          ),
        ),
        Padding(
          padding: widget.isMe!
              ? EdgeInsets.only(
                  right: 10.0,
                  bottom: 10.0,
                )
              : EdgeInsets.only(
                  left: 10.0,
                  bottom: 10.0,
                ),
          child: TextTime(
            child: Text(
              timeago.format(widget.time!.toDate()),
              style: TextStyle(
                color: Theme.of(context).textTheme.headline6!.color,
                fontSize: 10.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
