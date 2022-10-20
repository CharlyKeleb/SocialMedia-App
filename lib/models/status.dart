import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/enum/message_type.dart';

class StatusModel {
  String? caption;
  String? url;
  String? status;
  String? statusId;
  MessageType? type;
  List<dynamic>? viewers;
  Timestamp? time;

  StatusModel(
      {this.caption,
      this.url,
      this.statusId,
      this.time,
      this.type,
      this.viewers});

  StatusModel.fromJson(Map<String, dynamic> json) {
    url = json['url'];
    caption = json['caption'];
    statusId = json['statusId'];
    viewers = json['viewers'];
    if (json['type'] == 'text') {
      type = MessageType.TEXT;
    } else {
      type = MessageType.IMAGE;
    }
    time = json['time'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['caption'] = this.caption;
    data['statusId'] = this.statusId;
    data['viewers'] = this.viewers;
    data['url'] = this.url;
    if (this.type == MessageType.TEXT) {
      data['type'] = 'text';
    } else {
      data['type'] = 'image';
    }
    data['time'] = this.time;
    return data;
  }
}
