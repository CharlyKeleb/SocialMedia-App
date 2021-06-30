import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

FirebaseAuth firebaseAuth = FirebaseAuth.instance;
FirebaseFirestore firestore = FirebaseFirestore.instance;
FirebaseStorage storage = FirebaseStorage.instance;
final Uuid uuid = Uuid();

// Collection refs
CollectionReference usersRef = firestore.collection('users');
CollectionReference chatRef = firestore.collection("chats");
CollectionReference postRef = firestore.collection('posts');
CollectionReference storyRef = firestore.collection('posts');
CollectionReference commentRef = firestore.collection('comments');
CollectionReference notificationRef = firestore.collection('notifications');
CollectionReference followersRef = firestore.collection('followers');
CollectionReference followingRef = firestore.collection('following');
CollectionReference likesRef = firestore.collection('likes');
CollectionReference favUsersRef = firestore.collection('favoriteUsers');



// Storage refs
Reference profilePic =storage.ref().child('profilePic');
Reference posts =storage.ref().child('posts');