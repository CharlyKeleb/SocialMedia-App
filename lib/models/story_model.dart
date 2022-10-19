import 'package:cloud_firestore/cloud_firestore.dart';

class Status {
  final String uid;
  final String username;
  final List<String>? description;
  final List<String> photoUrl;
  final Timestamp createdAt;
  final String profilePic;
  final String statusId;
  final List<String> whoCanSee;

  Status({
    required this.uid,
    required this.username,
    required this.photoUrl,
    this.description,
    required this.createdAt,
    required this.profilePic,
    required this.statusId,
    required this.whoCanSee,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'description': description,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      'profilePic': profilePic,
      'statusId': statusId,
      'whoCanSee': whoCanSee,
    };
  }

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      description: List<String>.from(map['description']),
      photoUrl: List<String>.from(map['photoUrl']),
      createdAt: map['createdAt'],
      profilePic: map['profilePic'] ?? '',
      statusId: map['statusId'] ?? '',
      whoCanSee: List<String>.from(map['whoCanSee']),
    );
  }
}

// class ViewDetails {
//   List<String>? ids;
//   String? url;
//   String? description;
//
//   ViewDetails({this.ids, this.url, this.description});
//
//   Map<String, dynamic> toMap() {
//     return {
//       'ids': ids,
//     };
//   }
//
//   factory ViewDetails.fromMap(Map<String, dynamic> map) {
//     return ViewDetails(
//       ids: List<String>.from(map['id']),
//     );
//   }
// }
