import 'package:cloud_firestore/cloud_firestore.dart';

class StoryModel {
  String? id;
  String? postId;
  String? ownerId;
  String? username;
  String? caption;
  List<String>? mediaUrl;
  Timestamp? timestamp;

  StoryModel({
    this.id,
    this.postId,
    this.ownerId,
    this.caption,
    this.mediaUrl,
    this.username,
    this.timestamp,
  });

  StoryModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    postId = json['postId'];
    ownerId = json['ownerId'];
    username = json['username'];
    caption = json['caption'];
    mediaUrl = json['mediaUrl'];
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['postId'] = this.postId;
    data['ownerId'] = this.ownerId;
    data['caption'] = this.caption;
    data['mediaUrl'] = this.mediaUrl;
    data['timestamp'] = this.timestamp;
    data['username'] = this.username;
    return data;
  }
}
