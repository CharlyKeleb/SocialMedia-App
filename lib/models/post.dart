import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String postId;
  String ownerId;
  String username;
  String location;
  String description;
  String mediaUrl;
  dynamic likes;
  Timestamp timestamp;
  

  PostModel({
    this.postId,
    this.ownerId,
    this.location,
    this.description,
    this.mediaUrl,
    this.likes,
    this.username,
    this.timestamp,
  });
  PostModel.fromJson(Map<String, dynamic> json) {
    postId = json['postId'];
    ownerId = json['ownerId'];
    location = json['location'];
    username= json['username'];
    description = json['description'];
    mediaUrl = json['mediaUrl'];
    likes = json['likes'].length ?? 0;
    timestamp = json['timestamp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['postId'] = this.postId;
    data['ownerId'] = this.ownerId;
    data['location'] = this.location;
    data['description'] = this.description;
    data['mediaUrl'] = this.mediaUrl;
    data['likes'] = this.likes;
    data['timestamp'] = this.timestamp;
    data['username'] = this.username;
    return data;
  }

  int getLikeCount(likes) {
    // if no likes, return 0
    if (likes == null) {
      return 0;
    }
    int count = 0;
    // if the key is explicitly set to true, add a like
    likes.values.forEach((val) {
      if (val == true) {
        count += 1;
      }
    });
    return count;
  }
}
